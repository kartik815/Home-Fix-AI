import { Router, Request, Response } from "express";
import { getMongoDB } from "../config/mongodb";

const router = Router();

router.post("/", async (req: Request, res: Response) => {
  try {
    const {
      providerId,
      providerName,
      customerName,
      customerPhone,
      service,
      problem,
      date,
      time,
      notes,
    } = req.body;

    if (
      !providerId ||
      !providerName ||
      !customerName ||
      !customerPhone ||
      !service ||
      !date ||
      !time
    ) {
      return res.status(400).json({
        success: false,
        message: "Missing required booking information.",
      });
    }

    const db = getMongoDB();

    const booking = {
      providerId,
      providerName,
      customerName,
      customerPhone,
      service,
      problem: problem ?? "",
      date,
      time,
      notes: notes ?? "",
      status: "pending",
      createdAt: new Date(),
    };

    const result = await db
      .collection("bookings")
      .insertOne(booking);

    return res.status(201).json({
      success: true,
      message: "Booking created successfully.",
      data: {
        bookingId: result.insertedId.toString(),
        ...booking,
      },
    });
  } catch (error) {
    console.error("Create booking error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create booking.",
    });
  }
});

export default router;