import java.util.Arrays; 

int numBoxes;
Grid myGrid;
Box[] boxes;
int gridW;
int gridH;
String[] lines;
int populationSize = 200;             
int[][] population;                   
int[] fitnessScores;                 
float mutationRate = 0.2;            
int generations = 0;                  
int maxGenerations = 2000;           
int bestFitness;                     
int[] bestSolution;
PFont font;

void setup() {
    noLoop();
    size(1000,600);
    font = createFont("Arial",16,true);

    lines = loadStrings("boxes.txt");
    
    numBoxes = lines.length-1;
    println("numboxes: "+numBoxes);
    
    boxes = new Box[numBoxes];
    
    // first line is lorry dimensions, w,h
    String[] pieces = split(lines[0], ',');
    gridW = Integer.parseInt(pieces[0]);
    gridH = Integer.parseInt(pieces[1]);
    println("GridW: "+gridW);
    println("GridH: "+gridH);
    
    myGrid = new Grid(gridW, gridH);
    
    // read remaining lines, representing boxes
    for (int i=0; i<numBoxes; i++) {
        pieces = split(lines[i+1], ',');
        int w = Integer.parseInt(pieces[0]);
        int h = Integer.parseInt(pieces[1]);
        boxes[i] = new Box(w,h);
        println("Added Box no "+i+", w:"+w+", h:"+h);
    }
    
    // Initialize evolutionary algorithm
    population = new int[populationSize][numBoxes];
    fitnessScores = new int[populationSize];
    bestSolution = new int[numBoxes];
    bestFitness = Integer.MAX_VALUE;
    
    // Create initial random population
    for(int i = 0; i < populationSize; i++) {
        population[i] = createRandomSolution();
    }
}

int[] createRandomSolution() {
    int[] solution = new int[numBoxes];
    // Fill array with box indices
    for(int i = 0; i < numBoxes; i++) {
        solution[i] = i;
    }
    // Shuffle array
    for(int i = numBoxes-1; i > 0; i--) {
        int j = (int)random(i+1);
        int temp = solution[i];
        solution[i] = solution[j];
        solution[j] = temp;
    }
    return solution;
}

// Tournament selection: randomly pick two solutions, return the better one
int[] tournamentSelect() {
    int a = (int)random(populationSize);
    int b = (int)random(populationSize);
    if(fitnessScores[a] < fitnessScores[b]) {
        return population[a].clone();
    } else {
        return population[b].clone();
    }
}

// Crossover: combine two parent solutions to create a child solution
int[] crossover(int[] parent1, int[] parent2) {
    int[] child = new int[numBoxes];
    boolean[] used = new boolean[numBoxes];
    
    // Copy first half from parent1
    int midpoint = numBoxes/2;
    for(int i = 0; i < midpoint; i++) {
        child[i] = parent1[i];
        used[parent1[i]] = true;
    }
    
    // Fill remaining positions with numbers from parent2 in order
    int childPos = midpoint;
    for(int i = 0; i < numBoxes; i++) {
        int num = parent2[i];
        if(!used[num]) {
            child[childPos] = num;
            childPos++;
        }
    }
    
    return child;
}

// Mutation: randomly swap two positions
void mutate(int[] solution) {
    if(random(1) < mutationRate) {
        int i = (int)random(numBoxes);
        int j = (int)random(numBoxes);
        int temp = solution[i];
        solution[i] = solution[j];
        solution[j] = temp;
    }
}

// Evolve population
void evolve() {
    // Create new population
    int[][] newPopulation = new int[populationSize][numBoxes];
    
    // Elitism: keep best solution
    int bestIndex = 0;
    for(int i = 1; i < populationSize; i++) {
        if(fitnessScores[i] < fitnessScores[bestIndex]) {
            bestIndex = i;
        }
    }
    newPopulation[0] = population[bestIndex].clone();
    
    // Create rest of new population
    for(int i = 1; i < populationSize; i++) {
        // Select parents and create child
        int[] parent1 = tournamentSelect();
        int[] parent2 = tournamentSelect();
        int[] child = crossover(parent1, parent2);
        
        // Possibly mutate child
        mutate(child);
        
        newPopulation[i] = child;
    }
    
    // Replace old population
    population = newPopulation;
}

void draw() {
    // Calculate fitness for all solutions
    for(int i = 0; i < populationSize; i++) {
        fitnessScores[i] = myGrid.placeBoxes(boxes, population[i]);
        
        // Update best solution if this is better
        if(fitnessScores[i] < bestFitness) {
            bestFitness = fitnessScores[i];
            bestSolution = population[i].clone();
            println("Generation " + generations + ": New best fitness = " + bestFitness);
        }
    }

    // Find best index for logging
    int bestIndex = 0;
    for(int i = 1; i < populationSize; i++) {
        if(fitnessScores[i] < fitnessScores[bestIndex]) {
            bestIndex = i;
        }
    }
    
    if (generations % 10 == 0) {  // Log every 10 generations
        println("Generation: " + generations);
        println("Current Best Fitness: " + bestFitness);
        println("Best Solution: " + Arrays.toString(bestSolution));
        println("Population Best/Avg/Worst: " + 
            fitnessScores[bestIndex] + "/" + 
            calculateAverageFitness() + "/" + 
            findWorstFitness());
        println("-------------------");
    }

    if (validateSolution(bestSolution)) {
        println("Valid solution found!");
    } else {
        println("WARNING: Invalid solution structure!");
    }
    
    // Check if we found a perfect solution or hit max generations
    if(bestFitness == 0 || generations >= maxGenerations) {
        println("Evolution complete!");
        println("Best solution found with fitness: " + bestFitness);
        println("Solution: " + Arrays.toString(bestSolution));
        
        // Display best solution
        myGrid.placeBoxes(boxes, bestSolution);
        myGrid.draw(100,100,20,boxes);
        noLoop();
        return;
    }
    
    // Evolve population
    evolve();
    generations++;
    
    // Display current best solution
    myGrid.placeBoxes(boxes, bestSolution);
    myGrid.draw(100,100,20,boxes);
}

float calculateAverageFitness() {
    float sum = 0;
    for (int score : fitnessScores) {
        sum += score;
    }
    return sum / populationSize;
}

int findWorstFitness() {
    int worst = fitnessScores[0];
    for (int score : fitnessScores) {
        if (score > worst) worst = score;
    }
    return worst;
}

boolean validateSolution(int[] solution) {
    // Check length
    if (solution.length != numBoxes) {
        println("Invalid solution length: " + solution.length);
        return false;
    }
    
    // Check if all numbers 0 to numBoxes-1 are present
    boolean[] found = new boolean[numBoxes];
    for (int i = 0; i < solution.length; i++) {
        if (solution[i] < 0 || solution[i] >= numBoxes) {
            println("Invalid box number: " + solution[i]);
            return false;
        }
        if (found[solution[i]]) {
            println("Duplicate box number: " + solution[i]);
            return false;
        }
        found[solution[i]] = true;
    }
    
    // Verify all numbers were found
    for (int i = 0; i < numBoxes; i++) {
        if (!found[i]) {
            println("Missing box number: " + i);
            return false;
        }
    }
    
    return true;
}
