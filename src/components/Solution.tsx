"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import {
  Brain,
  Database,
  Cpu,
  ArrowRight,
  Check,
  X,
  Layers,
  Lock,
  Zap,
} from "lucide-react";

const oldStackItems = [
  "Salesforce",
  "HubSpot",
  "Zendesk",
  "Slack",
  "Monday.com",
  "ServiceNow",
];

const sovereignBenefits = [
  { icon: Lock, text: "100% Data Ownership" },
  { icon: Brain, text: "Custom AI Models" },
  { icon: Zap, text: "Autonomous Agents" },
  { icon: Layers, text: "Unified Architecture" },
];

export default function Solution() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section
      id="solutions"
      className="relative py-24 sm:py-32 overflow-hidden"
      ref={ref}
    >
      {/* Background accents */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-electric/5 rounded-full blur-[150px]" />
        <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-neon/5 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <span className="inline-block px-4 py-1.5 rounded-full text-sm font-medium bg-electric/10 border border-electric/20 text-electric mb-4">
            The Solution
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-6">
            <span className="text-gradient">Sovereign AI</span> Architecture
          </h2>
          <p className="max-w-3xl mx-auto text-gray-400 text-lg">
            We don&apos;t patch your existing stack. We replace it with a unified AI
            backbone that you own, control, and evolve. Built on Vector Databases
            and Large Language Models, customized to your business logic.
          </p>
        </motion.div>

        {/* Comparison Section */}
        <div className="grid lg:grid-cols-2 gap-8 lg:gap-16 items-center mb-20">
          {/* Old Stack */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            <div className="absolute -inset-4 bg-red-500/5 rounded-3xl blur-xl" />
            <div className="relative p-8 rounded-2xl bg-void-light border border-red-500/20">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-lg bg-red-500/20 flex items-center justify-center">
                  <X className="w-5 h-5 text-red-400" />
                </div>
                <h3 className="text-xl font-semibold text-white">
                  The Old Stack
                </h3>
              </div>

              {/* Messy logos representation */}
              <div className="grid grid-cols-3 gap-3 mb-6">
                {oldStackItems.map((item, i) => (
                  <motion.div
                    key={item}
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={isInView ? { opacity: 1, scale: 1 } : {}}
                    transition={{ delay: 0.3 + i * 0.1 }}
                    className="p-3 rounded-lg bg-glass border border-glass-border text-center"
                  >
                    <span className="text-xs text-gray-500 font-medium">
                      {item}
                    </span>
                  </motion.div>
                ))}
              </div>

              {/* Problems list */}
              <ul className="space-y-3">
                {[
                  "Fragmented data",
                  "Monthly fees forever",
                  "No AI integration",
                  "Vendor lock-in",
                ].map((problem) => (
                  <li
                    key={problem}
                    className="flex items-center gap-2 text-gray-400 text-sm"
                  >
                    <X className="w-4 h-4 text-red-400 flex-shrink-0" />
                    {problem}
                  </li>
                ))}
              </ul>
            </div>
          </motion.div>

          {/* Arrow */}
          <motion.div
            initial={{ opacity: 0, scale: 0.5 }}
            animate={isInView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.4, delay: 0.4 }}
            className="hidden lg:flex absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-20"
          >
            <div className="w-16 h-16 rounded-full bg-gradient-to-r from-electric to-neon flex items-center justify-center shadow-lg shadow-electric/30">
              <ArrowRight className="w-8 h-8 text-white" />
            </div>
          </motion.div>

          {/* Sovereign Stack */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative"
          >
            <div className="absolute -inset-4 bg-gradient-to-r from-electric/10 to-neon/10 rounded-3xl blur-xl" />
            <div className="relative p-8 rounded-2xl bg-void-light border border-electric/20">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-electric/20 to-neon/20 flex items-center justify-center">
                  <Check className="w-5 h-5 text-electric" />
                </div>
                <h3 className="text-xl font-semibold text-white">
                  The Sovereign Stack
                </h3>
              </div>

              {/* Central Intelligence Visual */}
              <div className="relative mb-6">
                <div className="flex justify-center">
                  <motion.div
                    animate={{
                      boxShadow: [
                        "0 0 20px rgba(59, 130, 246, 0.3)",
                        "0 0 40px rgba(139, 92, 246, 0.4)",
                        "0 0 20px rgba(59, 130, 246, 0.3)",
                      ],
                    }}
                    transition={{ duration: 3, repeat: Infinity }}
                    className="w-32 h-32 rounded-2xl bg-gradient-to-br from-electric/20 to-neon/20 border border-electric/30 flex flex-col items-center justify-center"
                  >
                    <Brain className="w-12 h-12 text-electric mb-2" />
                    <span className="text-xs text-gray-300 font-medium">
                      Central AI
                    </span>
                  </motion.div>
                </div>

                {/* Connected nodes */}
                <div className="absolute inset-0 flex items-center justify-between">
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={isInView ? { opacity: 1 } : {}}
                    transition={{ delay: 0.8 }}
                    className="w-12 h-12 rounded-lg bg-glass border border-glass-border flex items-center justify-center"
                  >
                    <Database className="w-5 h-5 text-neon" />
                  </motion.div>
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={isInView ? { opacity: 1 } : {}}
                    transition={{ delay: 0.9 }}
                    className="w-12 h-12 rounded-lg bg-glass border border-glass-border flex items-center justify-center"
                  >
                    <Cpu className="w-5 h-5 text-electric" />
                  </motion.div>
                </div>
              </div>

              {/* Benefits list */}
              <ul className="space-y-3">
                {sovereignBenefits.map((benefit, i) => (
                  <motion.li
                    key={benefit.text}
                    initial={{ opacity: 0, x: 20 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ delay: 0.5 + i * 0.1 }}
                    className="flex items-center gap-3 text-gray-300 text-sm"
                  >
                    <div className="w-6 h-6 rounded-md bg-electric/20 flex items-center justify-center flex-shrink-0">
                      <benefit.icon className="w-3.5 h-3.5 text-electric" />
                    </div>
                    {benefit.text}
                  </motion.li>
                ))}
              </ul>
            </div>
          </motion.div>
        </div>

        {/* Tech Stack Visual */}
        <motion.div
          id="tech"
          initial={{ opacity: 0, y: 40 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="glass-card rounded-2xl p-8 lg:p-12"
        >
          <h3 className="text-2xl font-semibold text-white mb-8 text-center">
            The Technology Behind Sovereign AI
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            {[
              {
                name: "Vector Databases",
                desc: "Semantic search & retrieval",
                icon: Database,
              },
              {
                name: "LLM Integration",
                desc: "GPT-4, Claude, Llama",
                icon: Brain,
              },
              {
                name: "Agent Framework",
                desc: "Autonomous task execution",
                icon: Cpu,
              },
              {
                name: "Your Infrastructure",
                desc: "On-prem or private cloud",
                icon: Lock,
              },
            ].map((tech, i) => (
              <motion.div
                key={tech.name}
                initial={{ opacity: 0, y: 20 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ delay: 0.8 + i * 0.1 }}
                className="text-center p-6 rounded-xl bg-glass border border-glass-border hover:border-electric/30 transition-colors duration-300"
              >
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-electric/20 to-neon/20 flex items-center justify-center mx-auto mb-4">
                  <tech.icon className="w-6 h-6 text-electric" />
                </div>
                <h4 className="text-white font-medium mb-1">{tech.name}</h4>
                <p className="text-sm text-gray-500">{tech.desc}</p>
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
