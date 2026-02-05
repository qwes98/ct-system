import java.time.Instant

plugins {
    java
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
}

group = "com.ctsystem"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

dependencies {
    // Spring Boot Core
    implementation(libs.bundles.spring.boot.core)

    // Database
    implementation(libs.bundles.database)

    // Database Migration
    implementation(libs.flyway.core)

    // Lombok
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    // Documentation
    implementation(libs.springdoc.openapi.starter.webmvc.ui)

    // Test
    testImplementation(libs.spring.boot.starter.test)
    testRuntimeOnly(libs.junit.platform.launcher)

    // Test Lombok support
    testCompileOnly(libs.lombok)
    testAnnotationProcessor(libs.lombok)
}

// Java Compile Options
tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
    options.compilerArgs.addAll(listOf(
        "-parameters",           // Preserve parameter names
        "-Xlint:deprecation",    // Warn on deprecated API usage
        "-Xlint:unchecked"       // Warn on unchecked operations
    ))
}

// Test Configuration
tasks.withType<Test> {
    useJUnitPlatform()

    // Test logging
    testLogging {
        events("passed", "skipped", "failed")
        showExceptions = true
        showCauses = true
        showStackTraces = true
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    }

    // JVM arguments for tests
    jvmArgs(
        "-XX:+EnableDynamicAgentLoading",
        "-Xshare:off"
    )

    // Generate reports
    reports {
        html.required = true
        junitXml.required = true
    }

    // Fail fast on CI
    systemProperty("junit.jupiter.execution.parallel.enabled", "false")
}

// Jar Configuration
tasks.jar {
    enabled = false  // Disable plain jar, use bootJar only
}

tasks.bootJar {
    archiveFileName = "ct-system-backend.jar"

    manifest {
        attributes(
            "Implementation-Title" to project.name,
            "Implementation-Version" to project.version,
            "Built-By" to System.getProperty("user.name"),
            "Built-Date" to Instant.now().toString()
        )
    }
}

// Clean task enhancement
tasks.clean {
    delete("out")  // IntelliJ output directory
}
