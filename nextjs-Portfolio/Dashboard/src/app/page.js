"use client";
import React from "react";
import { redirect } from "next/navigation";

const page = () => {
  redirect("/admin");
};

export default page;
