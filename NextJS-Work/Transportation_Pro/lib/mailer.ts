import nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT) || 587,
  secure: process.env.SMTP_SECURE === "true",
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Sender shown in the From field (using explicit email)
export const MAIL_FROM = "TransportPro <transport@devcodespace.com>";

// Recipient — all form submissions land here (testing)
export const MAIL_TO = "moiz.codexlancers@gmail.com";
