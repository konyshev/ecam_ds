package com.company;

import java.util.List;
import java.nio.file.Files;
import java.nio.file.Paths;

import com.sun.java.swing.plaf.windows.WindowsTreeUI.CollapsedIcon;

public class Main {

    public static void main(String[] args) {
        String fileName = "/home/yaroslav/Desktop/ECAM_formation/Java/CloudPoint/src/com/company/points.csv";
        //System.out.println(fileName);
        try{
            List<String> lines = Files.readAllLines(Paths.get(fileName));
            ICloudPoint points = importPoints(lines);
            points.displayAllPoints();
            displaySeparator();

            List<Point> listAjax = points.getAllPointWithNameContaining("Ajax");
            if (listAjax != null){
                for (Point l:listAjax){
                    System.out.println(l);
                }
            }
            displaySeparator();

            List<Point> list2D = points.getAll2DPoints();
            if (list2D != null){
                for (Point l:list2D){
                    System.out.println(l);
                }
            }
            displaySeparator();
            
            List<Point> list3D = points.getAll3DPoints();
            if (list3D != null){
                for (Point l:list3D){
                    System.out.println(l);
                }
            }
        }catch(Exception exception){
            System.out.println(String.format("File {0} not found", fileName));
            exception.printStackTrace();
        }
        
        /*
        if (!lines.isEmpty()){
            for (String l:lines){
                System.out.println(l);
            }
        } 
        */       
    }

    private static void displaySeparator(){
        System.out.println("------------");
    }

    private static ICloudPoint importPoints(List<String> lines){
        ICloudPoint points =new CloudPoint();

        for (String l:lines){
            Point p = null;
            String [] split = l.split(",");
            if (split.length == 3){
                p = get2DPoint(split);
            } else if (split.length == 4) {
                p = get3DPoint(split);
            } else {
                System.out.println("Not a valid point");
            }

            if(p != null){
                points.addPoint(p);
            } else {
                System.out.println("Invalid point : "+ split.toString());
            }

        }
        return points;
    } 

    private static Point get2DPoint(String[] split){
        return new Point(split[0],Integer.parseInt(split[1]),Integer.parseInt(split[2]));
    }

    private static Point get3DPoint(String[] split){
        return new Point3D(split[0],Integer.parseInt(split[1]),Integer.parseInt(split[2]),Integer.parseInt(split[3]));
    }

}
