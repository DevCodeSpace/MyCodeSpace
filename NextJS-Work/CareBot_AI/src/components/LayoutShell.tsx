"use client";

import { useState } from "react";
import AnnouncementTicker from "./AnnouncementTicker";
import Navbar from "./Navbar";
import Hero from "./Hero";

export default function LayoutShell() {
  const [tickerVisible, setTickerVisible] = useState(true);

  return (
    <>
      {tickerVisible && <AnnouncementTicker onDismiss={() => setTickerVisible(false)} />}
      <Navbar tickerVisible={tickerVisible} />
      <Hero tickerVisible={tickerVisible} />
    </>
  );
}
