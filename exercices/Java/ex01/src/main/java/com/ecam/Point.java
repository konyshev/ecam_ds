package com.ecam;
import java.lang.*;

public class Point implements Comparable {

    @Override
    public int compareTo(Object o) {
        if (o instanceof Point){
            Point p = (Point) o;
            return Integer.compare(this.getX(), p.getX());
        } else {
            return -1;
        }
    }

    private int x,y;
    private String name;

    public Point(String name, int x,int y){
        setX(x);
        setY(y);
        setName(name);
    }

    public void setName(String newValue) {
        this.name = newValue;
    }

    public String getName() {
        return this.name;
    }

    public void setX(int newValue) {
        this.x = newValue;
    }

    public void setY(int newValue) {
        this.y = newValue;
    }

    public int getX() {
        return this.x;
    }

    public int getY() {
        return this.y;
    }

    public String info() {
        return this.getName()+":("+this.getX()+","+this.getY()+")";
    }

    @Override
    public boolean equals(Object o) {
        Point point = (Point) o;
        return x==point.x &&
                y==point.y &&
                 java.util.Objects.equals(name,point.name);
    }

}