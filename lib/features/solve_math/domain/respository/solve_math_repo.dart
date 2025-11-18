/*
SolveMathRepo is an abstract class that defines the methods that the SolveMathRepository class must implement.

Here we define what the app can do
*/

import '../models/math_solution.dart';

abstract class SolveMathRepo {
  Future<MathSolution> solveMath(dynamic imageInput);
  Future<MathSolution> solveMathWithText(String textInput);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
