package com.rssignaturecapture.utils;

public class TimedPoint {
    public final float x;
    public final float y;
    public final long timestamp;

    public TimedPoint(float x, float y) {
        this.x = x;
        this.y = y;
        this.timestamp = System.currentTimeMillis();
    }

    public float velocityFrom(TimedPoint start) {
        long elapsed = this.timestamp - start.timestamp;
        if (elapsed <= 0) return 0f;
        float velocity = distanceTo(start) / elapsed;
        if (Float.isNaN(velocity) || Float.isInfinite(velocity)) return 0f;
        return velocity;
    }

    public float distanceTo(TimedPoint point) {
        return (float) Math.sqrt(Math.pow(point.x - this.x, 2) + Math.pow(point.y - this.y, 2));
    }
}
