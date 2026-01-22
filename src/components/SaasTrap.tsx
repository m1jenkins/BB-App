"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";
import { CreditCard, Database, Workflow } from "lucide-react";

const problems = [
  {
    icon: CreditCard,
    title: "The Rent Trap",
    description:
      "You pay monthly for software you'll never own. Prices rise; value stagnates. You're building equity for vendors, not for yourself.",
    gradient: "from-red-500/20 to-orange-500/20",
  },
  {
    icon: Database,
    title: "Data Silos",
    description:
      "Your proprietary data is locked inside vendor ecosystems, training their models, not yours. Your competitive advantage is leaking away.",
    gradient: "from-yellow-500/20 to-red-500/20",
  },
  {
    icon: Workflow,
    title: "Rigid Workflows",
    description:
      "Forced to adapt your business to their UI. We flip this: AI that adapts to you, not the other way around.",
    gradient: "from-orange-500/20 to-yellow-500/20",
  },
];

export default function SaasTrap() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 40 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: [0.25, 0.4, 0.25, 1] as const,
      },
    },
  };

  return (
    <section
      id="manifesto"
      className="relative py-24 sm:py-32 overflow-hidden"
      ref={ref}
    >
      {/* Background accent */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-red-500/5 rounded-full blur-[150px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-1.5 rounded-full text-sm font-medium bg-red-500/10 border border-red-500/20 text-red-400 mb-4">
            The Problem
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-6">
            The <span className="text-red-400">SaaS Trap</span>
          </h2>
          <p className="max-w-2xl mx-auto text-gray-400 text-lg">
            Enterprise software was supposed to empower you. Instead, it created
            a dependency that costs more every year and delivers less every
            update.
          </p>
        </motion.div>

        {/* Problem Cards */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate={isInView ? "visible" : "hidden"}
          className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8"
        >
          {problems.map((problem, index) => (
            <motion.div
              key={problem.title}
              variants={itemVariants}
              className="group relative"
            >
              {/* Card */}
              <div className="relative h-full p-8 rounded-2xl glass-card overflow-hidden">
                {/* Gradient overlay */}
                <div
                  className={`absolute inset-0 bg-gradient-to-br ${problem.gradient} opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
                />

                {/* Content */}
                <div className="relative z-10">
                  {/* Icon */}
                  <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-red-500/20 to-orange-500/20 border border-red-500/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                    <problem.icon className="w-7 h-7 text-red-400" />
                  </div>

                  {/* Number badge */}
                  <div className="absolute top-6 right-6 w-8 h-8 rounded-full bg-glass border border-glass-border flex items-center justify-center">
                    <span className="text-sm font-semibold text-gray-500">
                      {index + 1}
                    </span>
                  </div>

                  {/* Text */}
                  <h3 className="text-xl font-semibold text-white mb-4">
                    {problem.title}
                  </h3>
                  <p className="text-gray-400 leading-relaxed">
                    {problem.description}
                  </p>
                </div>

                {/* Hover border glow */}
                <div className="absolute inset-0 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                  <div className="absolute inset-0 rounded-2xl border border-red-500/30" />
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ delay: 0.8, duration: 0.6 }}
          className="text-center mt-16"
        >
          <p className="text-gray-500 text-lg">
            Sound familiar?{" "}
            <a
              href="#solutions"
              className="text-electric hover:text-electric-light transition-colors underline underline-offset-4"
            >
              There&apos;s a better way
            </a>
          </p>
        </motion.div>
      </div>
    </section>
  );
}
