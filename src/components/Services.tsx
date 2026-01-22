"use client";

import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import {
  Users,
  Settings,
  Headphones,
  ArrowUpRight,
  Sparkles,
} from "lucide-react";
import GlowButton from "./GlowButton";

const services = [
  {
    icon: Users,
    title: "Sales Agents",
    replaces: "Replaces CRM (Salesforce, HubSpot)",
    description:
      "Autonomous AI agents that qualify leads, nurture prospects, and close deals. They learn your sales playbook and execute it 24/7, with full context of every customer interaction.",
    features: [
      "Lead scoring & prioritization",
      "Automated outreach sequences",
      "Deal intelligence & forecasting",
      "CRM-free pipeline management",
    ],
    gradient: "from-blue-500 to-cyan-500",
    bgGradient: "from-blue-500/10 to-cyan-500/10",
  },
  {
    icon: Settings,
    title: "Ops Commanders",
    replaces: "Replaces ERP (SAP, Oracle, NetSuite)",
    description:
      "Intelligent operations agents that orchestrate your entire backend. From inventory to invoicing, they automate complex workflows that used to require armies of software.",
    features: [
      "Workflow automation",
      "Resource optimization",
      "Real-time analytics",
      "Cross-department coordination",
    ],
    gradient: "from-purple-500 to-pink-500",
    bgGradient: "from-purple-500/10 to-pink-500/10",
  },
  {
    icon: Headphones,
    title: "Support Neural Nets",
    replaces: "Replaces Zendesk, HelpScout, Intercom",
    description:
      "Customer support that actually understands. These agents resolve tickets autonomously, escalate intelligently, and continuously learn from every interaction.",
    features: [
      "Instant ticket resolution",
      "Multi-channel support",
      "Sentiment analysis",
      "Knowledge base automation",
    ],
    gradient: "from-green-500 to-emerald-500",
    bgGradient: "from-green-500/10 to-emerald-500/10",
  },
];

export default function Services() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section className="relative py-24 sm:py-32 overflow-hidden" ref={ref}>
      {/* Background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[1000px] h-[1000px] bg-neon/5 rounded-full blur-[200px]" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-1.5 rounded-full text-sm font-medium bg-neon/10 border border-neon/20 text-neon mb-4">
            Services
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-white mb-6">
            The <span className="text-gradient">Replacement</span> Strategy
          </h2>
          <p className="max-w-2xl mx-auto text-gray-400 text-lg">
            Each agent is custom-built for your business logic, trained on your
            data, and deployed on your infrastructure. No subscriptions. No
            vendor lock-in. Full ownership.
          </p>
        </motion.div>

        {/* Services Grid */}
        <div className="space-y-8 lg:space-y-12">
          {services.map((service, index) => (
            <motion.div
              key={service.title}
              initial={{ opacity: 0, y: 50 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.6, delay: index * 0.2 }}
              className={`relative group ${
                index % 2 === 1 ? "lg:flex-row-reverse" : ""
              }`}
            >
              <div
                className={`glass-card rounded-2xl p-8 lg:p-12 ${
                  index % 2 === 1 ? "lg:ml-auto" : ""
                }`}
              >
                <div
                  className={`grid lg:grid-cols-2 gap-8 items-center ${
                    index % 2 === 1 ? "lg:flex-row-reverse" : ""
                  }`}
                >
                  {/* Content */}
                  <div className={index % 2 === 1 ? "lg:order-2" : ""}>
                    <div className="flex items-center gap-4 mb-4">
                      <div
                        className={`w-14 h-14 rounded-xl bg-gradient-to-br ${service.bgGradient} border border-white/10 flex items-center justify-center`}
                      >
                        <service.icon
                          className={`w-7 h-7 bg-gradient-to-r ${service.gradient} bg-clip-text`}
                          style={{
                            color:
                              service.gradient === "from-blue-500 to-cyan-500"
                                ? "#3b82f6"
                                : service.gradient ===
                                  "from-purple-500 to-pink-500"
                                ? "#8b5cf6"
                                : "#22c55e",
                          }}
                        />
                      </div>
                      <div>
                        <h3 className="text-2xl font-bold text-white">
                          {service.title}
                        </h3>
                        <p className="text-sm text-gray-500">
                          {service.replaces}
                        </p>
                      </div>
                    </div>

                    <p className="text-gray-400 leading-relaxed mb-6">
                      {service.description}
                    </p>

                    <ul className="grid grid-cols-2 gap-3 mb-8">
                      {service.features.map((feature) => (
                        <li
                          key={feature}
                          className="flex items-center gap-2 text-sm text-gray-300"
                        >
                          <Sparkles className="w-4 h-4 text-neon flex-shrink-0" />
                          {feature}
                        </li>
                      ))}
                    </ul>

                    <a
                      href="#contact"
                      className="inline-flex items-center gap-2 text-electric hover:text-electric-light transition-colors group/link"
                    >
                      <span className="font-medium">Learn more</span>
                      <ArrowUpRight className="w-4 h-4 group-hover/link:translate-x-0.5 group-hover/link:-translate-y-0.5 transition-transform" />
                    </a>
                  </div>

                  {/* Visual */}
                  <div
                    className={`relative ${index % 2 === 1 ? "lg:order-1" : ""}`}
                  >
                    <div
                      className={`absolute inset-0 bg-gradient-to-br ${service.bgGradient} rounded-2xl blur-2xl opacity-50 group-hover:opacity-75 transition-opacity duration-500`}
                    />
                    <div className="relative aspect-square max-w-[300px] mx-auto rounded-2xl bg-void-lighter border border-glass-border p-8 flex items-center justify-center">
                      <motion.div
                        animate={{
                          scale: [1, 1.05, 1],
                        }}
                        transition={{
                          duration: 4,
                          repeat: Infinity,
                          ease: "easeInOut",
                        }}
                      >
                        <service.icon
                          className="w-24 h-24"
                          style={{
                            color:
                              service.gradient === "from-blue-500 to-cyan-500"
                                ? "#3b82f6"
                                : service.gradient ===
                                  "from-purple-500 to-pink-500"
                                ? "#8b5cf6"
                                : "#22c55e",
                          }}
                        />
                      </motion.div>

                      {/* Floating particles */}
                      {[...Array(6)].map((_, i) => (
                        <motion.div
                          key={i}
                          className={`absolute w-2 h-2 rounded-full bg-gradient-to-r ${service.gradient}`}
                          style={{
                            top: `${20 + Math.random() * 60}%`,
                            left: `${20 + Math.random() * 60}%`,
                          }}
                          animate={{
                            y: [0, -10, 0],
                            opacity: [0.3, 0.8, 0.3],
                          }}
                          transition={{
                            duration: 2 + Math.random() * 2,
                            repeat: Infinity,
                            delay: Math.random() * 2,
                          }}
                        />
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Bottom CTA */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="text-center mt-20"
        >
          <h3 className="text-2xl sm:text-3xl font-bold text-white mb-4">
            Ready to Build Your Sovereign Stack?
          </h3>
          <p className="text-gray-400 mb-8 max-w-xl mx-auto">
            Let&apos;s audit your current SaaS spend and show you exactly how much
            you&apos;ll save with custom AI agents.
          </p>
          <GlowButton size="lg" href="#contact">
            Get Your Free Audit
            <ArrowUpRight className="w-5 h-5 ml-1" />
          </GlowButton>
        </motion.div>
      </div>
    </section>
  );
}
