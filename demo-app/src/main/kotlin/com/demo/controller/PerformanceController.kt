package com.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import kotlin.math.cos
import kotlin.math.sin
import kotlin.system.measureTimeMillis

@RestController
class PerformanceController {
    
    private val logger = LoggerFactory.getLogger(PerformanceController::class.java)
    
    @GetMapping("/compute")
    fun computeIntensive(@RequestParam(defaultValue = "1000000") iterations: Int): Map<String, Any> {
        
        logger.info("Starting computation", mapOf(
            "iterations" to iterations,
            "architecture" to System.getProperty("os.arch"),
            "availableProcessors" to Runtime.getRuntime().availableProcessors()
        ))
        
        var sum = 0.0
        val executionTime = measureTimeMillis {
            repeat(iterations) {
                sum += sin(it.toDouble()) * cos(it.toDouble())
            }
        }
        
        val result = mapOf(
            "iterations" to iterations,
            "architecture" to System.getProperty("os.arch"),
            "processors" to Runtime.getRuntime().availableProcessors(),
            "executionTimeMs" to executionTime,
            "result" to sum
        )
        
        logger.info("Computation completed", result)
        
        return result
    }
}