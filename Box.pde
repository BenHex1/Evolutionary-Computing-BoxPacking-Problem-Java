class Box
{
  int width;
  int height;
  int red;
  int green;
  int blue;
  
  Box(int w, int h)
  {
    width=w;
    height=h;
    red=(int)random(255);
    green=(int)random(255);
    blue=(int)random(255);
  }
}
