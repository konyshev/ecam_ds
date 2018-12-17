package com.company;

public class Point {

    private int x,y;
    private String name;

    public Point(String name, int x,int y){
        setName(name);
        setX(x);
        setY(y);
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

    @Override
    public String toString() {
        return String.format("%s : %s",this.getName(),getCoordinates());
    }

    public String getCoordinates() {
        return String.format("(%d, %d)", getX(),getY());
    }
}