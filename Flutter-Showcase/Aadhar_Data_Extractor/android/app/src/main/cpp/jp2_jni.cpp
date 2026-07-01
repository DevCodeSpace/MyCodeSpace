#include <jni.h>
#include <android/log.h>
#include "openjpeg.h"
#include <cstring>
#include <vector>

#define LOG_TAG "JP2Decoder"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

struct MemStream {
    const OPJ_UINT8 *data;
    OPJ_SIZE_T size;
    OPJ_SIZE_T pos;
};

static OPJ_SIZE_T mem_read(void *buf, OPJ_SIZE_T n, void *ctx) {
    auto *ms = (MemStream *) ctx;
    OPJ_SIZE_T available = ms->size - ms->pos;
    if (available == 0) return (OPJ_SIZE_T) -1;
    OPJ_SIZE_T read = n < available ? n : available;
    memcpy(buf, ms->data + ms->pos, read);
    ms->pos += read;
    return read;
}

static OPJ_OFF_T mem_skip(OPJ_OFF_T n, void *ctx) {
    auto *ms = (MemStream *) ctx;
    if (n < 0 || ms->pos + (OPJ_SIZE_T) n > ms->size) return -1;
    ms->pos += (OPJ_SIZE_T) n;
    return n;
}

static OPJ_BOOL mem_seek(OPJ_OFF_T n, void *ctx) {
    auto *ms = (MemStream *) ctx;
    if (n < 0 || (OPJ_SIZE_T) n > ms->size) return OPJ_FALSE;
    ms->pos = (OPJ_SIZE_T) n;
    return OPJ_TRUE;
}

static void quiet_msg(const char *, void *) {}

extern "C"
JNIEXPORT jbyteArray JNICALL
Java_com_example_aadhar_1demo_1app_MainActivity_decodeJp2Native(
        JNIEnv *env, jobject, jbyteArray jp2Array) {

    jsize len = env->GetArrayLength(jp2Array);
    jbyte *bytes = env->GetByteArrayElements(jp2Array, nullptr);

    MemStream ms{(OPJ_UINT8 *) bytes, (OPJ_SIZE_T) len, 0};

    opj_dparameters_t params;
    opj_set_default_decoder_parameters(&params);

    // Detect J2K codestream vs JP2 container
    bool isJ2K = (len >= 2 &&
                  (unsigned char) bytes[0] == 0xFF &&
                  (unsigned char) bytes[1] == 0x4F);

    opj_codec_t *codec = opj_create_decompress(isJ2K ? OPJ_CODEC_J2K : OPJ_CODEC_JP2);
    opj_set_info_handler(codec, quiet_msg, nullptr);
    opj_set_warning_handler(codec, quiet_msg, nullptr);
    opj_set_error_handler(codec, quiet_msg, nullptr);

    opj_stream_t *stream = opj_stream_create(OPJ_J2K_STREAM_CHUNK_SIZE, OPJ_TRUE);
    opj_stream_set_user_data(stream, &ms, nullptr);
    opj_stream_set_user_data_length(stream, (OPJ_UINT64) len);
    opj_stream_set_read_function(stream, mem_read);
    opj_stream_set_skip_function(stream, mem_skip);
    opj_stream_set_seek_function(stream, mem_seek);

    opj_image_t *image = nullptr;
    jbyteArray result = nullptr;

    if (!opj_setup_decoder(codec, &params) ||
        !opj_read_header(stream, codec, &image) ||
        !opj_decode(codec, stream, image) ||
        !opj_end_decompress(codec, stream)) {
        LOGE("JP2 decode failed");
        goto cleanup;
    }

    {
        int w = (int) image->comps[0].w;
        int h = (int) image->comps[0].h;
        int numComps = (int) image->numcomps;

        // Build raw RGBA bytes
        std::vector<uint8_t> rgba(w * h * 4);
        for (int i = 0; i < w * h; i++) {
            int r, g, b;
            int shift = image->comps[0].prec - 8;
            if (numComps >= 3) {
                r = shift >= 0 ? (image->comps[0].data[i] >> shift) : (image->comps[0].data[i] << -shift);
                g = shift >= 0 ? (image->comps[1].data[i] >> shift) : (image->comps[1].data[i] << -shift);
                b = shift >= 0 ? (image->comps[2].data[i] >> shift) : (image->comps[2].data[i] << -shift);
            } else {
                r = g = b = shift >= 0 ? (image->comps[0].data[i] >> shift) : (image->comps[0].data[i] << -shift);
            }
            rgba[i * 4 + 0] = (uint8_t) (r < 0 ? 0 : r > 255 ? 255 : r);
            rgba[i * 4 + 1] = (uint8_t) (g < 0 ? 0 : g > 255 ? 255 : g);
            rgba[i * 4 + 2] = (uint8_t) (b < 0 ? 0 : b > 255 ? 255 : b);
            rgba[i * 4 + 3] = 0xFF;
        }

        // Return width, height, then RGBA bytes (caller builds Bitmap)
        // Format: [4 bytes width BE][4 bytes height BE][w*h*4 RGBA bytes]
        std::vector<uint8_t> out(8 + rgba.size());
        out[0] = (w >> 24) & 0xFF; out[1] = (w >> 16) & 0xFF;
        out[2] = (w >> 8) & 0xFF;  out[3] = w & 0xFF;
        out[4] = (h >> 24) & 0xFF; out[5] = (h >> 16) & 0xFF;
        out[6] = (h >> 8) & 0xFF;  out[7] = h & 0xFF;
        memcpy(out.data() + 8, rgba.data(), rgba.size());

        result = env->NewByteArray((jsize) out.size());
        env->SetByteArrayRegion(result, 0, (jsize) out.size(), (jbyte *) out.data());
    }

    cleanup:
    if (image) opj_image_destroy(image);
    opj_stream_destroy(stream);
    opj_destroy_codec(codec);
    env->ReleaseByteArrayElements(jp2Array, bytes, JNI_ABORT);
    return result;
}
