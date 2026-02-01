/**
 * Domain type definitions for CT-System frontend
 * Based on PRD specifications
 */

// Difficulty levels for problems
export type Difficulty = 'EASY' | 'MEDIUM' | 'HARD';

// Supported programming languages
export type Language = 'PYTHON' | 'JAVA' | 'CPP' | 'JAVASCRIPT';

// Submission status states (state machine)
export type SubmissionStatus = 'QUEUED' | 'RUNNING' | 'DONE';

// Problem entity
export interface Problem {
  id: number;
  title: string;
  description: string;
  difficulty: Difficulty;
  constraints: string[];
  timeLimit: number; // milliseconds
  memoryLimit: number; // MB
}

// Sample test case (visible to users during Run)
export interface SampleTestCase {
  id: number;
  input: string;
  expectedOutput: string;
}

// Submission entity
export interface Submission {
  id: number;
  problemId: number;
  language: Language;
  code: string;
  status: SubmissionStatus;
  isSuccess: boolean | null; // null while running
  hasError: boolean;
  createdAt: string; // ISO date string
}
