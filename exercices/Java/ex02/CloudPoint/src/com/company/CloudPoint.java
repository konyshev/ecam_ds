package com.company;

import java.util.List;
import java.util.Map;
import java.util.*;

public class CloudPoint implements ICloudPoint{
    private Map<String,Point> mapPoints;

    public CloudPoint(){
        this.mapPoints = new HashMap<String,Point>();
    }

    public void addPoint(Point point){
        this.mapPoints.put(point.getName(),point);
    }

    public void removePoint(String pointName){
        if (exists(pointName)){
            this.mapPoints.remove(pointName);
        }
    }

    public void movePoint(String pointName, Integer x, Integer y, Integer z){
        if (exists(pointName)){
        Point p = mapPoints.get(pointName);
        p.setX(x);
        p.setY(y);
            if (p instanceof Point3D){
                Point3D p3D = (Point3D) p;
                p3D.setZ(z);
            }
        }
    }
    
    public boolean exists(String name){
        return this.mapPoints.containsKey(name);
    }

    public List<Point> getAllPointWithNameContaining(String name){
        List<Point> pointList = new ArrayList<Point>();
        for (Point p: this.mapPoints.values()){
            if (p.getName().contains(name)) {
                pointList.add(p);
            }
        }
        return pointList;
    }

    public void displayAllPoints(){
        for(Map.Entry<String, Point> entry: mapPoints.entrySet()) {
            System.out.println(entry.getValue());
        }
    }

    public List<Point> getAll2DPoints(){
        List<Point> pointList = new ArrayList<Point>();
        for (Point p: this.mapPoints.values()){
            if (!(p instanceof Point3D)){
                pointList.add(p);
            } 
        }
        return pointList;
    }

    public List<Point> getAll3DPoints(){
        List<Point> pointList = new ArrayList<Point>();
        for (Point p: this.mapPoints.values()){
            if (p instanceof Point3D){
                pointList.add(p);
            } 
        }
        return pointList;
    }

    public Map<String, List<String>> groupByCoordinates(){
        throw new java.lang.UnsupportedOperationException();
    }

    public float getDistanceBetween(Point firstPoint, Point secondPoint){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getClosest2DPointFromOrigin(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getFarest2DPointFromOrigin(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getClosest3DPointFromOrigin(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getFarest3DPointFromOrigin(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWithMaxX(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWIthMaxY(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWIthMaxZ(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWithMinX(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWIthMinY(){
        throw new java.lang.UnsupportedOperationException();
    }

    public Point getPointWIthMinZ(){
        throw new java.lang.UnsupportedOperationException();
    }

}