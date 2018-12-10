package com.ecam;

import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner inputFromUser = new Scanner(System.in);
        System.out.println("Enter X:"); 
        int xFromUser = inputFromUser.nextInt();

        System.out.println("Enter Y:"); 
        int yFromUser = inputFromUser.nextInt();

        inputFromUser.close();

        Point p = new Point();
        p.setX(xFromUser);
        p.setY(yFromUser);
        System.out.println("X = "+p.getX()); // Display the string.
        System.out.println("Y = "+p.getY()); // Display the string.
    }
}