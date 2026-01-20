# Coding Convention

프로젝트 전체에 적용되는 코딩 컨벤션입니다.

## 1. 공통 규칙

### 1.1 일반 원칙

- **가독성 우선**: 간결함보다 명확함을 선택
- **일관성 유지**: 기존 코드 스타일을 따름
- **자기 문서화**: 이름만으로 의도가 드러나도록 작성
- **단일 책임**: 함수/클래스는 하나의 역할만 수행

### 1.2 네이밍 규칙 요약

| 대상 | Frontend (TS) | Backend (Java) |
|------|---------------|----------------|
| 파일명 (컴포넌트) | PascalCase.tsx | PascalCase.java |
| 파일명 (유틸) | camelCase.ts | PascalCase.java |
| 클래스/인터페이스 | PascalCase | PascalCase |
| 함수/메서드 | camelCase | camelCase |
| 변수 | camelCase | camelCase |
| 상수 | UPPER_SNAKE_CASE | UPPER_SNAKE_CASE |
| 타입/Enum | PascalCase | PascalCase |
| DB 컬럼 | snake_case | snake_case |

---

## 2. Frontend (TypeScript/React)

### 2.1 파일 구조

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (routes)/           # 라우트 그룹
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ui/                 # shadcn/ui 컴포넌트
│   │   ├── common/             # 공통 컴포넌트
│   │   └── features/           # 기능별 컴포넌트
│   ├── hooks/                  # 커스텀 훅
│   ├── lib/                    # 유틸리티
│   ├── services/               # API 클라이언트
│   ├── stores/                 # 상태 관리
│   └── types/                  # 타입 정의
```

### 2.2 컴포넌트 작성

**함수형 컴포넌트 사용:**

```tsx
// Good
interface ProblemCardProps {
  problem: Problem;
  onClick?: () => void;
}

export function ProblemCard({ problem, onClick }: ProblemCardProps) {
  return (
    <div className="rounded-lg border p-4" onClick={onClick}>
      <h3 className="font-semibold">{problem.title}</h3>
      <DifficultyBadge difficulty={problem.difficulty} />
    </div>
  );
}

// Bad - default export 사용
export default function ProblemCard() { ... }
```

**컴포넌트 파일 구조:**

```tsx
// 1. imports
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import type { Problem } from '@/types';

// 2. types
interface Props {
  problem: Problem;
}

// 3. component
export function ProblemCard({ problem }: Props) {
  // 3.1 hooks
  const [isLoading, setIsLoading] = useState(false);

  // 3.2 handlers
  const handleClick = () => {
    // ...
  };

  // 3.3 render
  return (
    <div>...</div>
  );
}
```

### 2.3 TypeScript

**타입 정의:**

```tsx
// Good - interface 선호 (확장 가능)
interface User {
  id: number;
  name: string;
}

// OK - type alias (union, intersection 필요시)
type Status = 'pending' | 'running' | 'done';
type ApiResponse<T> = { data: T } | { error: string };
```

**Strict 모드:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

### 2.4 스타일링 (Tailwind CSS)

**클래스 정렬 순서:**

```tsx
// 순서: 레이아웃 → 크기 → 여백 → 배경 → 테두리 → 텍스트 → 기타
<div className="flex flex-col w-full h-64 p-4 bg-white border rounded-lg text-gray-900 hover:shadow-lg">
```

**조건부 스타일:**

```tsx
import { cn } from '@/lib/utils';

<div className={cn(
  'rounded-lg p-4',
  isActive && 'bg-blue-500 text-white',
  isDisabled && 'opacity-50 cursor-not-allowed'
)} />
```

### 2.5 Import 정렬

```tsx
// 1. React/Next.js
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

// 2. 외부 라이브러리
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';

// 3. 내부 모듈 (절대 경로)
import { Button } from '@/components/ui/button';
import { useAuth } from '@/hooks/useAuth';

// 4. 타입
import type { Problem } from '@/types';

// 5. 상대 경로
import { helper } from './utils';
```

### 2.6 ESLint / Prettier 설정

```json
// .eslintrc.json
{
  "extends": [
    "next/core-web-vitals",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn",
    "prefer-const": "error"
  }
}
```

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

---

## 3. Backend (Java/Spring Boot)

### 3.1 패키지 구조

```
backend/
├── src/main/java/com/ctsystem/
│   ├── CtsystemApplication.java
│   ├── config/                 # 설정 클래스
│   ├── controller/             # REST 컨트롤러
│   ├── service/                # 비즈니스 로직
│   ├── repository/             # 데이터 접근
│   ├── domain/                 # 엔티티
│   ├── dto/                    # 데이터 전송 객체
│   │   ├── request/
│   │   └── response/
│   ├── exception/              # 예외 클래스
│   └── util/                   # 유틸리티
```

### 3.2 클래스 네이밍

| 유형 | 접미사 | 예시 |
|------|--------|------|
| Controller | Controller | `ProblemController` |
| Service | Service | `ProblemService` |
| Repository | Repository | `ProblemRepository` |
| Entity | (없음) | `Problem` |
| DTO (요청) | Request | `SubmitRequest` |
| DTO (응답) | Response | `ProblemResponse` |
| Exception | Exception | `ProblemNotFoundException` |
| Config | Config | `RedisConfig` |

### 3.3 Controller

```java
@RestController
@RequestMapping("/api/v1/problems")
@RequiredArgsConstructor
public class ProblemController {

    private final ProblemService problemService;

    @GetMapping
    public ApiResponse<Page<ProblemListResponse>> getProblems(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.success(problemService.getProblems(page, size));
    }

    @GetMapping("/{id}")
    public ApiResponse<ProblemDetailResponse> getProblem(@PathVariable Long id) {
        return ApiResponse.success(problemService.getProblem(id));
    }

    @PostMapping("/{id}/run")
    public ApiResponse<RunResponse> run(
            @PathVariable Long id,
            @Valid @RequestBody RunRequest request
    ) {
        return ApiResponse.success(problemService.run(id, request));
    }
}
```

### 3.4 Service

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProblemService {

    private final ProblemRepository problemRepository;
    private final TestCaseRepository testCaseRepository;

    public ProblemDetailResponse getProblem(Long id) {
        Problem problem = problemRepository.findById(id)
                .orElseThrow(() -> new ProblemNotFoundException(id));

        return ProblemDetailResponse.from(problem);
    }

    @Transactional
    public SubmitResponse submit(Long problemId, SubmitRequest request) {
        // 비즈니스 로직
    }
}
```

### 3.5 DTO

```java
// Request DTO
public record SubmitRequest(
        @NotNull Long problemId,
        @NotBlank String language,
        @NotBlank @Size(max = 65536) String code
) {}

// Response DTO
public record ProblemDetailResponse(
        Long id,
        String title,
        String description,
        String difficulty,
        List<String> constraints,
        Integer timeLimit,
        Integer memoryLimit
) {
    public static ProblemDetailResponse from(Problem problem) {
        return new ProblemDetailResponse(
                problem.getId(),
                problem.getTitle(),
                problem.getDescription(),
                problem.getDifficulty().name(),
                problem.getConstraints(),
                problem.getTimeLimit(),
                problem.getMemoryLimit()
        );
    }
}
```

### 3.6 Entity

```java
@Entity
@Table(name = "problems")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Problem extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Difficulty difficulty;

    @Column(nullable = false)
    private Integer timeLimit = 2000;

    @Column(nullable = false)
    private Integer memoryLimit = 512;

    @OneToMany(mappedBy = "problem", cascade = CascadeType.ALL)
    private List<TestCase> testCases = new ArrayList<>();

    // 생성자
    @Builder
    public Problem(String title, String description, Difficulty difficulty) {
        this.title = title;
        this.description = description;
        this.difficulty = difficulty;
    }

    // 비즈니스 메서드
    public void updateTitle(String title) {
        this.title = title;
    }
}
```

### 3.7 예외 처리

```java
// 커스텀 예외
public class ProblemNotFoundException extends BusinessException {
    public ProblemNotFoundException(Long id) {
        super(ErrorCode.PROBLEM_NOT_FOUND, "Problem with id " + id + " not found");
    }
}

// 전역 예외 핸들러
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<?>> handleBusinessException(BusinessException e) {
        return ResponseEntity
                .status(e.getErrorCode().getStatus())
                .body(ApiResponse.error(e.getErrorCode(), e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<?>> handleValidationException(
            MethodArgumentNotValidException e
    ) {
        // 검증 에러 처리
    }
}
```

### 3.8 Lombok 사용 규칙

**허용:**
- `@Getter`
- `@RequiredArgsConstructor`
- `@Builder`
- `@Slf4j`
- `@NoArgsConstructor(access = AccessLevel.PROTECTED)`

**제한적 사용:**
- `@Setter` - DTO에서만 사용
- `@Data` - 사용 금지 (명시적으로 필요한 것만 선언)
- `@AllArgsConstructor` - Builder와 함께 사용시에만

### 3.9 Checkstyle 설정

```xml
<!-- checkstyle.xml -->
<module name="Checker">
    <module name="TreeWalker">
        <module name="ConstantName"/>
        <module name="LocalVariableName"/>
        <module name="MemberName"/>
        <module name="MethodName"/>
        <module name="PackageName"/>
        <module name="ParameterName"/>
        <module name="TypeName"/>
        <module name="AvoidStarImport"/>
        <module name="UnusedImports"/>
    </module>
    <module name="FileLength">
        <property name="max" value="500"/>
    </module>
</module>
```

---

## 4. SQL / Database

### 4.1 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 테이블 | snake_case, 복수형 | `problems`, `test_cases` |
| 컬럼 | snake_case | `created_at`, `is_active` |
| 인덱스 | idx_{table}_{column} | `idx_problems_category` |
| FK 제약 | fk_{from}_{to} | `fk_testcases_problems` |
| PK 제약 | pk_{table} | `pk_problems` |

### 4.2 쿼리 작성

```sql
-- Good: 명시적이고 읽기 쉬움
SELECT
    p.id,
    p.title,
    p.difficulty,
    c.name AS category_name
FROM
    problems p
    LEFT JOIN categories c ON p.category_id = c.id
WHERE
    p.is_active = true
    AND p.difficulty = 'EASY'
ORDER BY
    p.created_at DESC
LIMIT 20 OFFSET 0;

-- Bad: 한 줄에 모든 것
SELECT p.id, p.title, p.difficulty, c.name AS category_name FROM problems p LEFT JOIN categories c ON p.category_id = c.id WHERE p.is_active = true AND p.difficulty = 'EASY' ORDER BY p.created_at DESC LIMIT 20 OFFSET 0;
```

---

## 5. Git

### 5.1 커밋 메시지

**형식:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type:**
| Type | 설명 |
|------|------|
| feat | 새로운 기능 |
| fix | 버그 수정 |
| docs | 문서 변경 |
| style | 포맷팅, 세미콜론 등 (코드 변경 X) |
| refactor | 리팩토링 |
| test | 테스트 추가/수정 |
| chore | 빌드, 설정 변경 |

**예시:**
```
feat(submission): add submission status polling

- Add polling mechanism for submission status
- Update UI to show real-time status

Closes #123
```

### 5.2 브랜치 네이밍

```
<type>/<issue-number>-<short-description>

예:
feat/42-add-submission-api
fix/56-run-timeout-error
refactor/78-improve-judge0-client
```

---

## 6. 테스트

### 6.1 테스트 네이밍

**Java (JUnit):**
```java
@Test
@DisplayName("유효한 제출 요청시 제출 ID를 반환한다")
void submit_WithValidRequest_ReturnsSubmissionId() {
    // given
    SubmitRequest request = new SubmitRequest(1L, "PYTHON", "print('hello')");

    // when
    SubmitResponse response = submissionService.submit(request);

    // then
    assertThat(response.submissionId()).isNotNull();
    assertThat(response.status()).isEqualTo("QUEUED");
}
```

**TypeScript (Jest/Vitest):**
```typescript
describe('SubmissionService', () => {
  describe('submit', () => {
    it('should return submission id when request is valid', async () => {
      // Arrange
      const request = { problemId: 1, language: 'PYTHON', code: "print('hello')" };

      // Act
      const result = await submissionService.submit(request);

      // Assert
      expect(result.submissionId).toBeDefined();
      expect(result.status).toBe('QUEUED');
    });
  });
});
```

### 6.2 테스트 구조

```
// Given-When-Then (BDD)
// Arrange-Act-Assert (AAA)

@Test
void methodName_StateUnderTest_ExpectedBehavior() {
    // given (arrange)
    // 테스트 데이터 준비

    // when (act)
    // 테스트 대상 실행

    // then (assert)
    // 결과 검증
}
```

---

## 7. 코드 리뷰 체크리스트

- [ ] 네이밍이 명확하고 일관적인가?
- [ ] 함수/메서드가 단일 책임을 가지는가?
- [ ] 불필요한 주석이 없는가? (코드가 자명한가?)
- [ ] 에러 처리가 적절한가?
- [ ] 테스트가 포함되어 있는가?
- [ ] 보안 취약점이 없는가?
- [ ] 성능 문제가 예상되지 않는가?
