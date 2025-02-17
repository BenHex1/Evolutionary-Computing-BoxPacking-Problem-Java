class Grid
{
  int [][] gridElement;
  int width;
  int height;
  
  Grid(int w, int h)
  {
    width=w;
    height=h;
    
    gridElement=new int[width][height];
    
    for (int row=0; row<height; row++)
    {
      for (int col=0; col<width; col++)
      {
        gridElement[col][row] = -1; // set all elements to "free"
      }
    }
  }
  
  int placeBoxes(Box[] boxes, int [] ordering)
  {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            gridElement[col][row] = -1;
        }
    }
    
    // Try to place each box in the given order
    for (int i = 0; i < ordering.length; i++) {
        int boxIndex = ordering[i];
        Box currentBox = boxes[boxIndex];
        boolean placed = false;
        
        // Try normal orientation
        placed = tryPlaceBox(currentBox.width, currentBox.height, boxIndex);
        
        // If failed, try rotated orientation
        if (!placed) {
            placed = tryPlaceBox(currentBox.height, currentBox.width, boxIndex);
        }
        
        // If box couldn't be placed in either orientation, return high penalty
        if (!placed) {
            return 1000000; // Large penalty for failing to place a box
        }
    }
    
    // Calculate fitness based on wasted space
    return calcFreeSpace();
  }
private boolean tryPlaceBox(int boxWidth, int boxHeight, int boxIndex) {
    // Find smallest dimensions of remaining unplaced boxes
    int minWidth = width;
    int minHeight = height;
    for (int i = 0; i < boxes.length; i++) {
        if (i == boxIndex) continue;
        
        boolean boxIsUnplaced = true;
        // Check if this box is already placed
        for (int r = 0; r < height; r++) {
            for (int c = 0; c < width; c++) {
                if (gridElement[c][r] == i) {
                    boxIsUnplaced = false;
                    break;
                }
            }
            if (!boxIsUnplaced) break;
        }
        
        if (boxIsUnplaced) {
            Box box = boxes[i];
            // Consider both orientations for minimum dimensions
            minWidth = Math.min(minWidth, Math.min(box.width, box.height));
            minHeight = Math.min(minHeight, Math.min(box.width, box.height));
        }
    }

    // Try each possible column as starting position, from right to left
    for (int col = width - boxWidth; col >= 0; col--) {
        int rowPos = findHighestPosition(col, boxWidth);
        
        if (rowPos >= 0 && rowPos + boxHeight <= height) {
            // Check if space is entirely free
            boolean spaceIsFree = true;
            for (int r = rowPos; r < rowPos + boxHeight; r++) {
                for (int c = col; c < col + boxWidth; c++) {
                    if (gridElement[c][r] != -1) {
                        spaceIsFree = false;
                        break;
                    }
                }
                if (!spaceIsFree) break;
            }
            
            if (spaceIsFree) {
                // Detailed gap analysis
                boolean canPlaceBox = true;
                
                // Check left side for unusable gaps
                if (col > 0) {
                    int leftGapWidth = 0;
                    for (int c = 0; c < col; c++) {
                        boolean columnEmpty = true;
                        for (int r = 0; r < height; r++) {
                            if (gridElement[c][r] != -1) {
                                columnEmpty = false;
                                break;
                            }
                        }
                        if (columnEmpty) {
                            leftGapWidth++;
                        } else {
                            break;
                        }
                    }
                    
                    // If gap is too small for any remaining box, cannot place
                    if (leftGapWidth > 0 && leftGapWidth < minWidth) {
                        canPlaceBox = false;
                    }
                }
                
                // Check bottom for unusable gaps
                if (canPlaceBox && rowPos + boxHeight < height) {
                    int bottomGapHeight = 0;
                    for (int r = rowPos + boxHeight; r < height; r++) {
                        boolean rowEmpty = true;
                        for (int c = col; c < col + boxWidth; c++) {
                            if (gridElement[c][r] != -1) {
                                rowEmpty = false;
                                break;
                            }
                        }
                        if (rowEmpty) {
                            bottomGapHeight++;
                        } else {
                            break;
                        }
                    }
                    
                    // If gap is too small for any remaining box, cannot place
                    if (bottomGapHeight > 0 && bottomGapHeight < minHeight) {
                        canPlaceBox = false;
                    }
                }
                
                // Check right side for unusable gaps
                if (canPlaceBox && col + boxWidth < width) {
                    int rightGapWidth = 0;
                    for (int c = col + boxWidth; c < width; c++) {
                        boolean columnEmpty = true;
                        for (int r = 0; r < height; r++) {
                            if (gridElement[c][r] != -1) {
                                columnEmpty = false;
                                break;
                            }
                        }
                        if (columnEmpty) {
                            rightGapWidth++;
                        } else {
                            break;
                        }
                    }
                    
                    // If gap is too small for any remaining box, cannot place
                    if (rightGapWidth > 0 && rightGapWidth < minWidth) {
                        canPlaceBox = false;
                    }
                }
                
                // If all gap checks pass, place the box
                if (canPlaceBox) {
                    fillGrid(rowPos, col, boxHeight, boxWidth, boxIndex);
                    return true;
                }
            }
        }
    }
    
    return false;
}
  
  private int findHighestPosition(int startCol, int boxWidth) {
    int maxHeight = -1;
    
    // Check all columns the box would occupy
    for (int col = startCol; col < startCol + boxWidth; col++) {
        int columnHeight = 0;
        // Find height of current column
        while (columnHeight < height && gridElement[col][columnHeight] != -1) {
            columnHeight++;
        }
        // Update maximum height found
        maxHeight = Math.max(maxHeight, columnHeight);
    }
    
    // Return -1 if no valid position found
    if (maxHeight >= height) {
        return -1;
    }
    
    return maxHeight;
  }
  
  void fillGrid(int fillRow, int fillCol, int th, int tw, int b)
  {
    for (int row = fillRow; row < fillRow + th; row++) {
        for (int col = fillCol; col < fillCol + tw; col++) {
            gridElement[col][row] = b;
        }
    }
  }  
    
  int findGap(String colRep, int th)
  {
    // code goes here
    return (0);
  }
  
  String coltoString(int c)
  {
    StringBuilder sb = new StringBuilder();
    for (int row = 0; row < height; row++) {
        sb.append(gridElement[c][row]);
    }
    return sb.toString();
  }   
 
  int calcFreeSpace() {
    int freeSpaces = 0;
    int unreachableSpaces = 0;
    
    // For each column
    for (int col = 0; col < width; col++) {
        for (int row = 0; row < height; row++) {
            if (gridElement[col][row] == -1) {
                // This space is empty
                freeSpaces++;
                
                // Check if it's unreachable (blocked from the left)
                boolean blocked = false;
                for (int checkCol = 0; checkCol < col; checkCol++) {
                    if (gridElement[checkCol][row] != -1) {
                        blocked = true;
                        break;
                    }
                }
                if (blocked) {
                    // Heavily penalize unreachable spaces
                    unreachableSpaces++;
                }
            }
        }
    }
    
    // Return total wasted space with extra penalty for unreachable spaces
    return freeSpaces + (unreachableSpaces * 1000);
  }
  
  void draw(int x, int y, int size, Box[] boxes)
  {
    // x,y define top-left of grid drawing, size is the "pixel" size
    
    fill(255,255,255);
    rect(x-size,y-size,(width+2)*size,(height+2)*size);
    
    for (int row=0; row<height; row++)
    {
      for (int col=0; col<width; col++)
      {
        int spaceValue=gridElement[col][row];
        int drawx;
        int drawy;
        int rounding=5; // used for rounded corners
        drawx=(col*size)+x;
        drawy=(row*size)+y;
        
        if (spaceValue == -1) // empty space
        {
          fill(255,255,255); // white
          stroke(0,0,0);
          rect(drawx, drawy, size, size, rounding);
          fill(0,0,0);
          textFont(font,8);
          text(""+spaceValue, drawx+(size/2)-4, drawy+(size/2));
        }  
        else // there's a box there, so get its colour
        {
          fill(boxes[spaceValue].red, boxes[spaceValue].green, boxes[spaceValue].blue);
          stroke(0,0,0);
          rect(drawx, drawy, size, size, rounding);
          textFont(font,8);
          fill(255,255,255);
          text(""+spaceValue, drawx+(size/2)-4, drawy+(size/2));
        } 
      }
    }
  } 
}
