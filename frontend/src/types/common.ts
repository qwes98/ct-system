/**
 * Common utility type definitions for CT-System frontend
 */

// Nullable type helper
export type Nullable<T> = T | null;

// Optional type helper
export type Optional<T> = T | undefined;

// Async state for data fetching patterns
export interface AsyncState<T> {
  data: T | null;
  isLoading: boolean;
  error: string | null;
}

// Pagination request params
export interface PaginationParams {
  page: number;
  size: number;
}

// Paginated response wrapper
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  size: number;
  totalPages: number;
}
