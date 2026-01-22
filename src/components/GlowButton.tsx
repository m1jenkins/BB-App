"use client";

import { motion } from "framer-motion";
import { ReactNode } from "react";

interface GlowButtonProps {
  children: ReactNode;
  variant?: "primary" | "secondary";
  size?: "sm" | "md" | "lg";
  onClick?: () => void;
  href?: string;
  className?: string;
}

export default function GlowButton({
  children,
  variant = "primary",
  size = "md",
  onClick,
  href,
  className = "",
}: GlowButtonProps) {
  const sizeClasses = {
    sm: "px-4 py-2 text-sm",
    md: "px-6 py-3 text-base",
    lg: "px-8 py-4 text-lg",
  };

  const baseClasses = `
    relative inline-flex items-center justify-center
    font-semibold rounded-lg
    transition-all duration-300 ease-out
    ${sizeClasses[size]}
    ${className}
  `;

  const primaryClasses = `
    bg-gradient-to-r from-electric to-neon
    text-white
    hover:shadow-[0_0_30px_rgba(59,130,246,0.5),0_0_60px_rgba(139,92,246,0.3)]
  `;

  const secondaryClasses = `
    bg-transparent
    text-white
    border border-glass-border
    hover:border-electric/50
    hover:bg-glass-hover
  `;

  const variantClasses = variant === "primary" ? primaryClasses : secondaryClasses;

  const buttonContent = (
    <motion.span
      className={`${baseClasses} ${variantClasses}`}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.2 }}
    >
      {/* Glow effect for primary variant */}
      {variant === "primary" && (
        <motion.span
          className="absolute inset-0 rounded-lg bg-gradient-to-r from-electric to-neon opacity-0 blur-xl"
          animate={{
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
      )}
      <span className="relative z-10 flex items-center gap-2">{children}</span>
    </motion.span>
  );

  if (href) {
    return (
      <a href={href} onClick={onClick}>
        {buttonContent}
      </a>
    );
  }

  return (
    <button onClick={onClick} type="button">
      {buttonContent}
    </button>
  );
}
