import { AnimatePresence, motion } from "framer-motion";

export const BlurFade = ({
  children,
  className,
  variant = {
    hidden: { y: 20, opacity: 0, filter: "blur(4px)" },
    visible: { y: 0, opacity: 1, filter: "blur(0px)" },
  },
  duration = 0.4,
  delay = 0,
  yOffset = 6,
  inView = false,
  inViewMargin = "-50px",
  blur = "6px",
}) => {
  // Customizable variants
  const defaultVariants = {
    hidden: { y: yOffset, opacity: 0, filter: `blur(${blur})` },
    visible: { y: -0, opacity: 1, filter: `blur(0px)` },
  };
  const combinedVariants = variant || defaultVariants;

  return (
    <AnimatePresence>
      <motion.div
        initial="hidden"
        animate={inView ? undefined : "visible"}
        whileInView={inView ? "visible" : undefined}
        viewport={{ once: true, margin: inViewMargin }}
        variants={combinedVariants}
        transition={{
          delay: 0.04 + delay,
          duration,
          ease: "easeOut",
        }}
        className={className}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
};
