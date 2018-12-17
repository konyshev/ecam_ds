package com.ecam;

import java.util.*;
import java.util.Iterator;

public class Main {
    public static void main(String[] args) {
        List<Point> points = new ArrayList<Point>(10);
        Map<String,Point> mapPoints = new HashMap<String,Point>();

        String[] names = {"A","B","C","D","E","F","G","H","I","J"};
        int[] abscissa = {1,2,4,-2,-3,-3,5,6,0,0};
        int[] ordinate = {3,0,3,3,1,4,-3,-1,2,5};

        for(int i = 0; i< names.length ;i++){
            points.add(new Point(names[i], abscissa[i], ordinate[i]));
        }

		Iterator<Point> pointsIterator = points.iterator();
		while (pointsIterator.hasNext()) {
            Point p = pointsIterator.next();
            System.out.println(p.toString());
            mapPoints.put(p.getName(),p);
        }

        Scanner inputFromUser = new Scanner(System.in);
        System.out.println("Enter a point name:"); 
        String nameFromUser = inputFromUser.nextLine();
 //       int numberOfPoints = 0;

        Point foundPoint = mapPoints.get(nameFromUser);
        if (foundPoint != null) {
            System.out.println(" User wanted --> "+foundPoint.toString());
        }
/*
        for(Point p:points){
            if (p.getName().equals(nameFromUser)){
                System.out.println(" User wanted --> "+p.info());
            }
            if (p.getX()==0 || p.getY()==0)
            {
                System.out.println(" X or Y is zero --> "+p.info());
                numberOfPoints++;
            }            
        }

        System.out.println(numberOfPoints + " point(s) with zero coordinate");

        if(points.elementAt(0).equals(points.elementAt(9))){
            System.out.println(" equal! ");
        }
        else {
            System.out.println(" not equal! ");
        }

        Collections.sort(points);

        for(Point p:points){
            System.out.println(p.info());
        }
*/
        inputFromUser.close();
    }
}