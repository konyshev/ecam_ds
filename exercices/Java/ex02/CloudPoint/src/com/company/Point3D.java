package com.company;

public class Point3D extends Point {

    private int z;

    public Point3D(String name, int x,int y,int z){
        super(name,x,y);
        setZ(z);
    }

    public void setZ(int newValue) {
        this.z = newValue;
    }

    public int getZ() {
        return this.z;
    }

    @Override
    public String getCoordinates() {
        return String.format("(%d, %d, %d)", getX(),getY(),getZ());
    }

}