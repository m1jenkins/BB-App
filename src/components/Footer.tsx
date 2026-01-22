"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import { Mail, Linkedin, Twitter, Github, ArrowUpRight } from "lucide-react";
import GlowButton from "./GlowButton";

const socialLinks = [
  { name: "LinkedIn", icon: Linkedin, href: "#" },
  { name: "Twitter", icon: Twitter, href: "#" },
  { name: "GitHub", icon: Github, href: "#" },
];

const footerLinks = [
  { name: "Privacy Policy", href: "#" },
  { name: "Terms of Service", href: "#" },
  { name: "Security", href: "#" },
];

export default function Footer() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <footer id="contact" className="relative pt-24 pb-12 overflow-hidden" ref={ref}>
      {/* Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-gradient-to-t from-electric/10 to-transparent rounded-full blur-[100px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Contact Section */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="glass-card rounded-2xl p-8 lg:p-16 mb-16"
        >
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Left - Text */}
            <div>
              <span className="inline-block px-4 py-1.5 rounded-full text-sm font-medium bg-electric/10 border border-electric/20 text-electric mb-4">
                Let&apos;s Talk
              </span>
              <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
                Ready to Own Your{" "}
                <span className="text-gradient">Intelligence?</span>
              </h2>
              <p className="text-gray-400 text-lg mb-8">
                Book a free 30-minute consultation. We&apos;ll audit your current SaaS
                stack and show you the path to sovereign AI.
              </p>

              <div className="flex flex-col sm:flex-row gap-4">
                <GlowButton size="lg" href="mailto:hello@sovereignlogic.ai">
                  <Mail className="w-5 h-5 mr-2" />
                  hello@sovereignlogic.ai
                </GlowButton>
                <GlowButton variant="secondary" size="lg" href="#">
                  Schedule a Call
                  <ArrowUpRight className="w-5 h-5 ml-1" />
                </GlowButton>
              </div>
            </div>

            {/* Right - Visual */}
            <div className="relative">
              <motion.div
                className="aspect-square max-w-[400px] mx-auto rounded-2xl bg-gradient-to-br from-electric/10 to-neon/10 border border-glass-border p-8 flex items-center justify-center"
                animate={{
                  boxShadow: [
                    "0 0 40px rgba(59, 130, 246, 0.2)",
                    "0 0 60px rgba(139, 92, 246, 0.3)",
                    "0 0 40px rgba(59, 130, 246, 0.2)",
                  ],
                }}
                transition={{ duration: 4, repeat: Infinity }}
              >
                <div className="text-center">
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{
                      duration: 20,
                      repeat: Infinity,
                      ease: "linear",
                    }}
                    className="w-32 h-32 mx-auto mb-6 rounded-full border-2 border-dashed border-electric/30 flex items-center justify-center"
                  >
                    <div className="w-24 h-24 rounded-full bg-gradient-to-br from-electric to-neon flex items-center justify-center">
                      <span className="text-4xl font-bold text-white">SL</span>
                    </div>
                  </motion.div>
                  <p className="text-white font-semibold text-lg">
                    Sovereign Logic
                  </p>
                  <p className="text-gray-500 text-sm">
                    Build Your Own Intelligence
                  </p>
                </div>
              </motion.div>
            </div>
          </div>
        </motion.div>

        {/* Bottom Footer */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="flex flex-col md:flex-row items-center justify-between gap-8 pt-8 border-t border-glass-border"
        >
          {/* Logo & Copyright */}
          <div className="text-center md:text-left">
            <a href="#" className="inline-block mb-2">
              <span className="text-xl font-bold">
                <span className="text-white">Sovereign</span>
                <span className="text-gradient"> Logic</span>
              </span>
            </a>
            <p className="text-sm text-gray-500">
              &copy; {new Date().getFullYear()} Sovereign Logic. All rights
              reserved.
            </p>
          </div>

          {/* Links */}
          <div className="flex flex-wrap justify-center gap-6">
            {footerLinks.map((link) => (
              <a
                key={link.name}
                href={link.href}
                className="text-sm text-gray-500 hover:text-white transition-colors"
              >
                {link.name}
              </a>
            ))}
          </div>

          {/* Social Links */}
          <div className="flex items-center gap-4">
            {socialLinks.map((social) => (
              <a
                key={social.name}
                href={social.href}
                aria-label={social.name}
                className="w-10 h-10 rounded-lg bg-glass border border-glass-border flex items-center justify-center text-gray-400 hover:text-white hover:border-electric/30 transition-all duration-300"
              >
                <social.icon className="w-5 h-5" />
              </a>
            ))}
          </div>
        </motion.div>
      </div>
    </footer>
  );
}
