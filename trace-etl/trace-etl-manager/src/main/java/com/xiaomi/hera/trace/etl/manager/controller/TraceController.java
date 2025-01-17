package com.xiaomi.hera.trace.etl.manager.controller;

import com.xiaomi.hera.trace.etl.api.service.DataSourceService;
import com.xiaomi.hera.trace.etl.domain.tracequery.TraceIdQueryVo;
import com.xiaomi.hera.trace.etl.domain.tracequery.TraceListQueryVo;
import com.xiaomi.hera.trace.etl.domain.tracequery.TraceOperationsVo;
import com.xiaomi.hera.trace.etl.domain.tracequery.TraceQueryResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @Description
 * @Author dingtao
 * @Date 2022/11/7 11:37 上午
 */
@RestController
@RequestMapping("/tracing/v1")
@Slf4j
public class TraceController {

    @Autowired
    private DataSourceService queryEsService;

    @Value("${es.trace.index.prefix}")
    private String spanIndexPrefix;

    @Value("${es.trace.index.service.prefix}")
    private String serviceIndexPrefix;

    @GetMapping(value = "/app/operations")
    public TraceQueryResult operations(TraceOperationsVo vo) {
        vo.setIndex(serviceIndexPrefix);
        return queryEsService.getOperations(vo);
    }

    @GetMapping(value = "/trace/list")
    public TraceQueryResult getList(TraceListQueryVo vo) {
        vo.setIndex(spanIndexPrefix);
        return queryEsService.getList(vo);
    }

    @GetMapping(value = "/trace/{traceId}")
    public TraceQueryResult getByTraceId(@PathVariable String traceId, TraceIdQueryVo vo) {
        vo.setIndex(spanIndexPrefix);
        vo.setTraceId(traceId);
        return queryEsService.getByTraceId(vo);
    }
}
