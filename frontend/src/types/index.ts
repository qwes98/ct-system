/**
 * Type definitions barrel export for CT-System frontend
 * Import types from '@/types' instead of individual files
 */

// Domain types
export type {
  Difficulty,
  Language,
  SubmissionStatus,
  Problem,
  SampleTestCase,
  Submission,
} from './domain';

// API types
export type {
  ApiResponse,
  ApiError,
  RunRequest,
  RunResponse,
  SubmitRequest,
  SubmitResponse,
} from './api';

// Common types
export type {
  Nullable,
  Optional,
  AsyncState,
  PaginationParams,
  PaginatedResponse,
} from './common';
