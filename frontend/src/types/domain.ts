/**
 * Domain type definitions for CT-System frontend
 * Based on API_SPECIFICATION.md
 */

// Difficulty levels for problems
export type Difficulty = 'EASY' | 'MEDIUM' | 'HARD';

// Supported programming languages
export type Language = 'PYTHON' | 'JAVA' | 'CPP' | 'JAVASCRIPT';

// Submission status states (state machine)
export type SubmissionStatus = 'QUEUED' | 'RUNNING' | 'DONE';

// Submission result types
export type SubmissionResult =
  | 'ACCEPTED'
  | 'WRONG_ANSWER'
  | 'RUNTIME_ERROR'
  | 'COMPILATION_ERROR'
  | 'TIME_LIMIT_EXCEEDED'
  | 'MEMORY_LIMIT_EXCEEDED';

// Problem example (visible to users)
export interface ProblemExample {
  input: string;
  output: string;
  explanation: string | null;
}

// Problem entity (full details from GET /problems/{problemId})
export interface Problem {
  id: number;
  title: string;
  description: string;
  difficulty: Difficulty;
  category: string;
  constraints: string[];
  examples: ProblemExample[];
  timeLimit: number; // milliseconds
  memoryLimit: number; // MB
  supportedLanguages: Language[];
  sampleTestCount: number;
  hiddenTestCount: number;
}

// Problem list item (from GET /problems)
export interface ProblemListItem {
  id: number;
  title: string;
  difficulty: Difficulty;
  category: string;
  acceptanceRate: number;
  submissionCount: number;
}

// Sample test case (visible to users during Run)
export interface SampleTestCase {
  id: number;
  input: string;
  expectedOutput: string;
}

// Submission entity (from GET /submissions/{submissionId})
export interface Submission {
  submissionId: string;
  problemId: number;
  problemTitle?: string;
  language: Language;
  status: SubmissionStatus;
  result?: SubmissionResult;
  totalTests?: number;
  passedTests?: number;
  hasError: boolean;
  executionTime?: number;
  memoryUsed?: number;
  createdAt: string; // ISO date string
  completedAt?: string;
  queuePosition?: number;
  progress?: {
    completed: number;
    total: number;
  };
}

// Submission history list item (from GET /submissions)
export interface SubmissionListItem {
  submissionId: string;
  problemId: number;
  problemTitle: string;
  language: Language;
  result: SubmissionResult;
  passedTests: number;
  totalTests: number;
  executionTime: number;
  createdAt: string;
}
