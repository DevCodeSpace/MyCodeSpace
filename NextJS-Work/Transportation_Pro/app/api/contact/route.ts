import { NextRequest, NextResponse } from "next/server";
import { MAIL_FROM, MAIL_TO, transporter } from "../../../lib/mailer";

// ── Server-side validation ──────────────────────────────────────────────────
function validateContact(data: Record<string, string>) {
  const errors: Record<string, string> = {};

  const name = data.name?.trim() ?? "";
  const phone = data.phone?.trim() ?? "";
  const company = data.company?.trim() ?? "";
  const message = data.message?.trim() ?? "";

  if (!name) {
    errors.name = "Full name is required.";
  } else if (name.length < 2) {
    errors.name = "Name must be at least 2 characters.";
  } else if (name.length > 100) {
    errors.name = "Name must be under 100 characters.";
  }

  if (!phone) {
    errors.phone = "Phone number is required.";
  } else {
    const cleaned = phone.replace(/[\s\-()]/g, "");
    // Accept: 10-digit Indian numbers (starting 6-9), or +91/0 prefix variants
    if (!/^(\+91|91|0)?[6-9]\d{9}$/.test(cleaned)) {
      errors.phone =
        "Enter a valid Indian mobile number (e.g. +91 7405545576).";
    }
  }

  if (company.length > 100) {
    errors.company = "Company name must be under 100 characters.";
  }

  // Email validation (required)
  const email = data.email?.trim() ?? "";
  if (!email) {
    errors.email = "Email address is required.";
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      errors.email = "Enter a valid email address.";
    }
  }

  // Industry validation (optional)
  const industry = data.industry?.trim() ?? "";
  // No required check – just ensure it's a string; you could add length limits if desired.

  if (message.length > 1000) {
    errors.message = "Message must be under 1000 characters.";
  }

  return errors;
}

export async function POST(req: NextRequest) {
  const body = await req.json();
  const errors = validateContact(body);

  if (Object.keys(errors).length > 0) {
    return NextResponse.json({ errors }, { status: 400 });
  }

  const { name, company, phone, email, industry, message } = body as Record<
    string,
    string
  >;

  try {
    await transporter.sendMail({
      from: MAIL_FROM,
      to: MAIL_TO,
      subject: `New Demo Request from ${name.trim()}`,
      html: `
        <div style="font-family:Arial, sans-serif; padding:20px; background:#f5f5f5;">
          <div style="max-width:600px; margin:auto; background:#ffffff; border-radius:8px; overflow:hidden; border:1px solid #e0e0e0;">
            <div style="background:#0C1B33; color:#ffffff; padding:20px; text-align:center;">
              <h2 style="margin:0; font-size:24px;">New Contact Form Submission</h2>
            </div>
            <div style="padding:20px; color:#333; line-height:1.5;">
              <p><strong>Name:</strong> ${name.trim()}</p>
              ${company?.trim() ? `<p><strong>Company:</strong> ${company.trim()}</p>` : ""}
              <p><strong>Phone / WhatsApp:</strong> ${phone.trim()}</p>
              ${email?.trim() ? `<p><strong>Email:</strong> ${email.trim()}</p>` : ""}
              ${industry?.trim() ? `<p><strong>Industry:</strong> ${industry.trim()}</p>` : ""}
              ${message?.trim() ? `<p><strong>Message:</strong><br/>${message.trim().replace(/\n/g, "<br/>")}</p>` : ""}
            </div>
            <div style="background:#f0f0f0; padding:10px; text-align:center; font-size:12px; color:#777;">
              Sent via TransportPro Contact Form
            </div>
          </div>
        </div>
      `,
    });

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error("[contact] Mail error:", err);
    return NextResponse.json(
      { error: "Failed to send email. Please try again." },
      { status: 500 },
    );
  }
}
