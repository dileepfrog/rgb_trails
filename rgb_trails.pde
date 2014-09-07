// Kinect Basic Example by Amnon Owed (15/09/12)

// interfaces with Kinect
import SimpleOpenNI.*;
import processing.opengl.*;
import blobDetection.*;

// declare SimpleOpenNI object
SimpleOpenNI kinect;

// blob detection and storage in a custom Polygon
BlobDetection theBlobDetection;
PolygonBlob poly = new PolygonBlob();

// PImage to hold incoming imagery and smaller one for blob detection
PImage cam, blobs;

int kinectWidth = 640;
int kinectHeight = 480;

// to center and rescale from 640x480 to higher custom resolutions
float reScale;

void setup() {
  // same as Kinect dimensions
  size(kinectWidth, kinectHeight, P2D);
  // initialize SimpleOpenNI object
  kinect = new SimpleOpenNI(this);
  if (!kinect.enableDepth()) {
    // if context.enableDepth() returns false
    // then the Kinect is not working correctly
    // make sure the green light is blinking
    println("Kinect not connected!");
    exit();
  } else {
    kinect.enableUser();
    // mirror the image to be more intuitive
    kinect.setMirror(true);
  }
  
  // calculate the reScale value
  // currently it's rescaled to fill the complete width (cuts of top-bottom)
  // it's also possible to fill the complete height (leaves empty sides)
  reScale = (float) width / kinectWidth;
  
  // create a smaller blob image for speed and efficiency
  blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);
  // initialize blob detection object to the blob image dimensions
  theBlobDetection = new BlobDetection(blobs.width, blobs.height);
  theBlobDetection.setThreshold(0.1);
}

void draw() {
  background(0);
  
  // center and reScale from Kinect to custom dimensions
  //translate(0, (height-kinectHeight*reScale)/2);
  //scale(reScale);
  
  // update the SimpleOpenNI object
  kinect.update();
  
  // put the image into a PImage
  cam = new PImage(kinectWidth, kinectHeight);
  cam.loadPixels();
  int[] u = kinect.userMap();
  for(int i =0;i<u.length;i++){
    if(u[i]==0){
      cam.pixels[i] = color(0);
    }
    else  {
      cam.pixels[i] = color(255,0,0);
    }
  }
  cam.updatePixels();
  
  // copy the image into the smaller blob image
  blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
  // blur the blob image
  blobs.filter(BLUR);
  // detect the blobs
  theBlobDetection.computeBlobs(blobs.pixels);
  // clear the polygon (original functionality)
  poly.reset();
  // create the polygon from the blobs (custom functionality, see class)
  poly.createPolygon();
  
  // display the image
  PShape person = createShape();
  person.beginShape();
  person.fill(255, 0, 0);
  for (int i = 0; i < poly.npoints; i++) {
    person.vertex(poly.xpoints[i], poly.ypoints[i]);
  }
  person.endShape(CLOSE);
  
  shape(person, 0, 0);
  //image(blobs, 0, 0);
}
