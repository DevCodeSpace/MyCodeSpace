"use client";
import { useRef, useState } from "react";
import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { cn } from "@/lib/utils";

export const TiltedCard = ({
  children,
  className,
  containerClassName,

  // tooltip
  captionText = "",
  showTooltip = true,

  // behavior
  scaleOnHover = 1.05,
  rotateAmplitude = 15,

  // spotlight
  showSpotlight = true,
  showSpotlightBackground = "bg-white/10", // 👈 Tailwind bg class
  spotlightSize = 260, // px
  spotlightOpacity = 0.18, // 0..1
}) => {
  const ref = useRef(null);

  // normalized mouse (-0.5..0.5) for tilt
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  // px mouse inside card (for tooltip + spotlight)
  const px = useMotionValue(0);
  const py = useMotionValue(0);

  // springs
  const mouseXSpring = useSpring(x, { damping: 30, stiffness: 200, mass: 1 });
  const mouseYSpring = useSpring(y, { damping: 30, stiffness: 200, mass: 1 });

  const scale = useSpring(1, { damping: 30, stiffness: 200, mass: 1 });

  const tooltipOpacity = useSpring(0, { damping: 30, stiffness: 200, mass: 1 });
  const tooltipRotate = useSpring(0, { stiffness: 350, damping: 30, mass: 1 });

  const spotlightOpacitySpring = useSpring(0, {
    damping: 30,
    stiffness: 200,
    mass: 1,
  });

  // map normalized mouse -> rotation
  const rotateX = useTransform(
    mouseYSpring,
    [-0.5, 0.5],
    [`${rotateAmplitude}deg`, `-${rotateAmplitude}deg`],
  );
  const rotateY = useTransform(
    mouseXSpring,
    [-0.5, 0.5],
    [`-${rotateAmplitude}deg`, `${rotateAmplitude}deg`],
  );

  const [lastOffsetY, setLastOffsetY] = useState(0);

  const handleMouseMove = (e) => {
    if (!ref.current) return;

    const rect = ref.current.getBoundingClientRect();
    const width = rect.width;
    const height = rect.height;

    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    // normalized tilt inputs
    x.set(mouseX / width - 0.5);
    y.set(mouseY / height - 0.5);

    // px for overlays (add small offset so tooltip doesn't sit under cursor)
    px.set(mouseX + 12);
    py.set(mouseY + 12);

    // velocity-based tooltip rotation
    const offsetYFromCenter = mouseY - height / 2;
    const velocityY = offsetYFromCenter - lastOffsetY;
    tooltipRotate.set(-velocityY * 0.6);
    setLastOffsetY(offsetYFromCenter);
  };

  const handleMouseEnter = () => {
    scale.set(scaleOnHover);
    tooltipOpacity.set(1);
    spotlightOpacitySpring.set(spotlightOpacity);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
    scale.set(1);
    tooltipOpacity.set(0);
    tooltipRotate.set(0);
    spotlightOpacitySpring.set(0);
    setLastOffsetY(0);
  };

  return (
    <div
      ref={ref}
      className={cn("relative", containerClassName)}
      onMouseMove={handleMouseMove}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      <motion.div
        style={{
          rotateY,
          rotateX,
          scale,
          transformStyle: "preserve-3d",
        }}
        className="relative z-10"
      >
        <div
          className={cn("relative bg-white", className)}
          style={{
            transform: "translateZ(50px)",
            transformStyle: "preserve-3d",
          }}
        >
          {/* SPOTLIGHT (behind content) */}
          {showSpotlight ? (
            <motion.div
              aria-hidden="true"
              className={cn(
                "pointer-events-none absolute inset-0 z-[0]",
                showSpotlightBackground, // 👈 Tailwind bg class
              )}
              style={{
                opacity: spotlightOpacitySpring,
                maskImage: useTransform(
                  px,
                  (v) =>
                    `radial-gradient(${spotlightSize}px ${spotlightSize}px at ${v}px ${py.get()}px, black 0%, transparent 60%)`,
                ),
                WebkitMaskImage: useTransform(
                  px,
                  (v) =>
                    `radial-gradient(${spotlightSize}px ${spotlightSize}px at ${v}px ${py.get()}px, black 0%, transparent 60%)`,
                ),
              }}
            />
          ) : null}

          {/* Content above spotlight */}
          <div className="relative z-[1]">{children}</div>
        </div>
      </motion.div>

      {/* TOOLTIP (outside 3D surface, always on top) */}
      {showTooltip && captionText ? (
        <motion.div
          className="pointer-events-none absolute left-0 top-0 z-[9999] hidden sm:block rounded-[4px] bg-white px-[10px] py-[4px] text-[10px] text-[#2d2d2d]"
          style={{
            x: px,
            y: py,
            opacity: tooltipOpacity,
            rotate: tooltipRotate,
          }}
        >
          {captionText}
        </motion.div>
      ) : null}
    </div>
  );
};
