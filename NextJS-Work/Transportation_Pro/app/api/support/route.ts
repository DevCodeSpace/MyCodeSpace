import { NextRequest, NextResponse } from "next/server";
import { MAIL_FROM, MAIL_TO, transporter } from "../../../lib/mailer";

// ── Server-side validation ──────────────────────────────────────────────────
function validateSupport(data: Record<string, string>) {
  const errors: Record<string, string> = {};

  const firstName = data.firstName?.trim() ?? "";
  const email = data.email?.trim() ?? "";
  const message = data.message?.trim() ?? "";

  if (!firstName) {
    errors.firstName = "First name is required.";
  } else if (firstName.length < 2) {
    errors.firstName = "First name must be at least 2 characters.";
  } else if (firstName.length > 50) {
    errors.firstName = "First name must be under 50 characters.";
  }

  if (!email) {
    errors.email = "Email address is required.";
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.email = "Enter a valid email address.";
  }

  if (!message) {
    errors.message = "Message is required.";
  } else if (message.length < 10) {
    errors.message = "Message must be at least 10 characters.";
  } else if (message.length > 2000) {
    errors.message = "Message must be under 2000 characters.";
  }

  return errors;
}

export async function POST(req: NextRequest) {
  const body = await req.json();
  const errors = validateSupport(body);

  if (Object.keys(errors).length > 0) {
    return NextResponse.json({ errors }, { status: 400 });
  }

  const { firstName, lastName, email, message } = body as Record<string, string>;
  const fullName = [firstName.trim(), lastName?.trim()].filter(Boolean).join(" ");

  try {
    await transporter.sendMail({
      from: MAIL_FROM,
      to: MAIL_TO,
      replyTo: email.trim(),
      subject: `Support Request from ${fullName}`,
      html: `
        <div style="font-family:Arial, sans-serif; padding:20px; background:#f5f5f5;">
          <div style="max-width:600px; margin:auto; background:#ffffff; border-radius:8px; overflow:hidden; border:1px solid #e0e0e0;">
            <div style="background:#0C1B33; color:#ffffff; padding:20px; text-align:center;">
              <h2 style="margin:0; font-size:24px;">New Support Form Submission</h2>
            </div>
            <div style="padding:20px; color:#333; line-height:1.5;">
              <p><strong>Name:</strong> ${fullName}</p>
              <p><strong>Email:</strong> <a href=\"mailto:${email.trim()}\" style=\"color:#0C1B33;\">${email.trim()}</a></p>
              ${message?.trim() ? `<p><strong>Message:</strong><br/>${message.trim().replace(/\\n/g, "<br/>")}</p>` : ""}
            </div>
            <div style="background:#f0f0f0; padding:10px; text-align:center; font-size:12px; color:#777;">
              Sent via TransportPro Support Page — reply directly to respond to the user.
            </div>
          </div>
        </div>
      `,
    });

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error("[support] Mail error:", err);
    return NextResponse.json({ error: "Failed to send email. Please try again." }, { status: 500 });
  }
}
