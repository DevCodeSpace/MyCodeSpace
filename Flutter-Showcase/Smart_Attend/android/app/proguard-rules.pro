# tflite_flutter exposes GPU delegate APIs, but Smart Attend uses the CPU
# interpreter path. R8 can safely ignore the optional GPU API class.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
