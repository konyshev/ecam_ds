package com.ecam;

import java.util.Scanner;
import java.util.*;

public class Main {
    public static void main(String[] args) {
        Vector<Point> points = new Vector<Point>(10);

        String[] names = {"A","B","C","D","E","F","G","H","I","J"};
        int[] abscissa = {1,2,4,-2,-3,-3,5,6,0,0};
        int[] ordinate = {3,0,3,3,1,4,-3,-1,2,5};

        for(int i = 0; i< names.length ;i++){
            points.add(new Point(names[i], abscissa[i], ordinate[i]));
        }
        
        for(Point p:points){
            System.out.println(p.info());
        }

//        Scanner inputFromUser = new Scanner(System.in);
//        System.out.println("Enter a point name:"); 
//        String nameFromUser = inputFromUser.nextLine();
        int numberOfPoints = 0;
   
        for(Point p:points){
//            if (p.getName().equals(nameFromUser)){
//                System.out.println(" User wanted --> "+p.info());
//            }
            if (p.getX()==0 || p.getY()==0)
            {
                System.out.println(" X or Y is zero --> "+p.info());
                numberOfPoints++;
            }            
        }

        System.out.println(numberOfPoints + " point(s) with zero coordinate");
/*
        if(points.elementAt(0).equals(points.elementAt(9))){
            System.out.println(" equal! ");
        }
        else {
            System.out.println(" not equal! ");
        }
*/
        Collections.sort(points);

        for(Point p:points){
            System.out.println(p.info());
        }

//        inputFromUser.close();
    }
}