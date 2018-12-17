package com.company;

import java.util.List;
import java.util.Map;

public interface ICloudPoint {
    void addPoint(Point point);
    void removePoint(String PointName);
    void movePoint(String pointName, Integer x, Integer y, Integer z);
    boolean exists(String name);
    List<Point> getAllPointWithNameContaining(String name);
    void displayAllPoints();
    List<Point> getAll2DPoints();
    List<Point> getAll3DPoints();
    Map<String, List<String>> groupByCoordinates();
    float getDistanceBetween(Point firstPoint, Point secondPoint);
    Point getClosest2DPointFromOrigin();
    Point getFarest2DPointFromOrigin();
    Point getClosest3DPointFromOrigin();
    Point getFarest3DPointFromOrigin();
    Point getPointWithMaxX();
    Point getPointWIthMaxY();
    Point getPointWIthMaxZ();
    Point getPointWithMinX();
    Point getPointWIthMinY();
    Point getPointWIthMinZ();
}
