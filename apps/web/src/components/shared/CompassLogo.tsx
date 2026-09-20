"use client";
import React, { useEffect, useRef } from 'react';

interface CompassLogoProps {
  className?: string;
  size?: number;
}

export function CompassLogo({ className = '', size = 40 }: CompassLogoProps) {
  const compassRef = useRef<SVGSVGElement>(null);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!compassRef.current) return;
      
      const rect = compassRef.current.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      
      const deltaX = e.clientX - centerX;
      const deltaY = e.clientY - centerY;
      
      // Calculate angle in degrees
      const angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI) + 90; // Add 90 so North points up
      
      // We will only rotate the inner star/needle for a cool effect, or the whole thing.
      // Let's rotate the whole SVG for simplicity, but smoothly.
      compassRef.current.style.transform = `rotate(${angle}deg)`;
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return (
    <div 
      className={`relative flex items-center justify-center ${className}`}
      style={{ width: size, height: size }}
    >
      <svg
        ref={compassRef}
        viewBox="0 0 200 200"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-full h-full transition-transform duration-100 ease-out drop-shadow-md"
        style={{ transformOrigin: 'center' }}
      >
        {/* Outer Ring */}
        <circle cx="100" cy="100" r="90" stroke="currentColor" strokeWidth="4" />
        <circle cx="100" cy="100" r="80" stroke="currentColor" strokeWidth="1.5" />
        
        {/* Cross Hairs */}
        <line x1="100" y1="10" x2="100" y2="190" stroke="currentColor" strokeWidth="1" strokeDasharray="4 4" />
        <line x1="10" y1="100" x2="190" y2="100" stroke="currentColor" strokeWidth="1" strokeDasharray="4 4" />
        <line x1="36" y1="36" x2="164" y2="164" stroke="currentColor" strokeWidth="1" strokeDasharray="4 4" />
        <line x1="36" y1="164" x2="164" y2="36" stroke="currentColor" strokeWidth="1" strokeDasharray="4 4" />

        {/* N, E, S, W Indicators (Static) - We'll put them outside the rotated part if we only rotated the needle, but since we rotate the whole thing, they spin! */}
        
        {/* The 4-point Main Star (Needles) */}
        {/* North Pointer */}
        <polygon points="100,20 115,100 100,100" fill="currentColor" />
        <polygon points="100,20 85,100 100,100" fill="currentColor" fillOpacity="0.3" />
        
        {/* South Pointer */}
        <polygon points="100,180 115,100 100,100" fill="currentColor" fillOpacity="0.3" />
        <polygon points="100,180 85,100 100,100" fill="currentColor" />
        
        {/* East Pointer */}
        <polygon points="180,100 100,115 100,100" fill="currentColor" />
        <polygon points="180,100 100,85 100,100" fill="currentColor" fillOpacity="0.3" />
        
        {/* West Pointer */}
        <polygon points="20,100 100,115 100,100" fill="currentColor" fillOpacity="0.3" />
        <polygon points="20,100 100,85 100,100" fill="currentColor" />

        {/* 4-point Secondary Star (Smaller) */}
        <polygon points="150,50 108,100 100,100" fill="currentColor" />
        <polygon points="150,50 100,92 100,100" fill="currentColor" fillOpacity="0.3" />
        
        <polygon points="50,150 100,108 100,100" fill="currentColor" />
        <polygon points="50,150 92,100 100,100" fill="currentColor" fillOpacity="0.3" />
        
        <polygon points="150,150 100,108 100,100" fill="currentColor" fillOpacity="0.3" />
        <polygon points="150,150 108,100 100,100" fill="currentColor" />
        
        <polygon points="50,50 92,100 100,100" fill="currentColor" />
        <polygon points="50,50 100,92 100,100" fill="currentColor" fillOpacity="0.3" />
        
        {/* Center Dot */}
        <circle cx="100" cy="100" r="6" fill="white" stroke="currentColor" strokeWidth="2" />
      </svg>
    </div>
  );
}
