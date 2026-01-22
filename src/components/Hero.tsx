"use client";

import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import GlowButton from "./GlowButton";
import NeuralBackground from "./NeuralBackground";

export default function Hero() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.8,
        ease: [0.25, 0.4, 0.25, 1] as const,
      },
    },
  };

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden pt-20">
      {/* Animated Neural Network Background */}
      <NeuralBackground />

      {/* Gradient Orbs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-1/4 -left-32 w-96 h-96 bg-electric/20 rounded-full blur-[128px]"
          animate={{
            x: [0, 50, 0],
            y: [0, 30, 0],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute bottom-1/4 -right-32 w-96 h-96 bg-neon/20 rounded-full blur-[128px]"
          animate={{
            x: [0, -50, 0],
            y: [0, -30, 0],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
          className="space-y-8"
        >
          {/* Badge */}
          <motion.div variants={itemVariants}>
            <span className="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-medium bg-glass border border-glass-border text-gray-300">
              <span className="w-2 h-2 rounded-full bg-electric mr-2 animate-pulse" />
              Next-Gen Enterprise AI
            </span>
          </motion.div>

          {/* Main Headline */}
          <motion.h1
            variants={itemVariants}
            className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight leading-tight"
          >
            <span className="text-white">Stop Renting Intelligence.</span>
            <br />
            <span className="text-gradient">Build Your Own.</span>
          </motion.h1>

          {/* Subheadline */}
          <motion.p
            variants={itemVariants}
            className="max-w-3xl mx-auto text-lg sm:text-xl text-gray-400 leading-relaxed"
          >
            Traditional SaaS is the old way. We replace your fragmented subscription
            stack with autonomous, custom AI Agents that live on{" "}
            <span className="text-white font-medium">your own infrastructure</span>.
          </motion.p>

          {/* CTA Buttons */}
          <motion.div
            variants={itemVariants}
            className="flex flex-col sm:flex-row gap-4 justify-center items-center pt-4"
          >
            <GlowButton size="lg" href="#solutions">
              Initialize Transformation
              <ArrowRight className="w-5 h-5 ml-1" />
            </GlowButton>
            <GlowButton variant="secondary" size="lg" href="#manifesto">
              Read Our Manifesto
            </GlowButton>
          </motion.div>

          {/* Trust Indicators */}
          <motion.div
            variants={itemVariants}
            className="pt-12 border-t border-glass-border/50 mt-12"
          >
            <p className="text-sm text-gray-500 mb-6">
              Trusted by forward-thinking enterprises
            </p>
            <div className="flex flex-wrap justify-center items-center gap-8 opacity-50">
              {["ENTERPRISE", "FINTECH", "HEALTHCARE", "LOGISTICS"].map(
                (name, i) => (
                  <motion.span
                    key={name}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 0.5 }}
                    transition={{ delay: 1 + i * 0.1 }}
                    className="text-sm font-semibold tracking-widest text-gray-400"
                  >
                    {name}
                  </motion.span>
                )
              )}
            </div>
          </motion.div>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 1.5, duration: 0.8 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
          className="w-6 h-10 rounded-full border-2 border-gray-600 flex items-start justify-center p-1"
        >
          <motion.div
            animate={{ opacity: [0.5, 1, 0.5], y: [0, 12, 0] }}
            transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
            className="w-1.5 h-3 rounded-full bg-gradient-to-b from-electric to-neon"
          />
        </motion.div>
      </motion.div>
    </section>
  );
}
