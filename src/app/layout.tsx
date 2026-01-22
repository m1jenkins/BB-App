import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Sovereign Logic | Build Your Own Intelligence",
  description:
    "Stop renting generic SaaS. We build custom Agentic AI assets that you own 100%. Transform your enterprise with autonomous AI agents on your own infrastructure.",
  keywords: [
    "AI consulting",
    "Agentic AI",
    "Enterprise AI",
    "Custom AI development",
    "AI agents",
    "SaaS replacement",
    "Vector databases",
    "LLM integration",
  ],
  authors: [{ name: "Sovereign Logic" }],
  openGraph: {
    title: "Sovereign Logic | Build Your Own Intelligence",
    description:
      "Stop renting generic SaaS. We build custom Agentic AI assets that you own 100%.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "Sovereign Logic | Build Your Own Intelligence",
    description:
      "Stop renting generic SaaS. We build custom Agentic AI assets that you own 100%.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="bg-void text-white antialiased min-h-screen overflow-x-hidden">
        <div className="relative">
          {/* Neural network gradient overlay */}
          <div className="fixed inset-0 bg-neural-gradient pointer-events-none z-0" />
          {/* Main content */}
          <div className="relative z-10">{children}</div>
        </div>
      </body>
    </html>
  );
}
