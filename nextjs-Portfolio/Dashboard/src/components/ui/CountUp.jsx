"use client";
import { useEffect, useRef } from "react";
import { useInView, useMotionValue, useSpring } from "framer-motion";

export const CountUp = ({
  value,
  direction = "up",
  delay = 0,
  className,
  prefix = "",
  suffix = "",
}) => {
  const ref = useRef(null);
  const motionValue = useMotionValue(direction === "down" ? value : 0);
  const springValue = useSpring(motionValue, {
    damping: 30,
    stiffness: 100,
  });
  const isInView = useInView(ref, { once: true, margin: "-50px" });

  useEffect(() => {
    if (isInView) {
      motionValue.set(direction === "down" ? 0 : value);
    }
  }, [isInView, motionValue, direction, value]);

  useEffect(() => {
    springValue.on("change", (latest) => {
      if (ref.current) {
        ref.current.textContent = `${prefix}${Intl.NumberFormat("en-US").format(
          latest.toFixed(0),
        )}${suffix}`;
      }
    });
  }, [springValue, prefix, suffix]);

  return <span className={className} ref={ref} />;
};
