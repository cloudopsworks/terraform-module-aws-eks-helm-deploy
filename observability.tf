##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  datadog   = try(var.observability.enabled, false) && try(var.observability.agent, "") == "datadog"
  xray      = try(var.observability.enabled, false) && try(var.observability.agent, "") == "xray"
  dynatrace = try(var.observability.enabled, false) && try(var.observability.agent, "") == "dynatrace"
  newrelic  = try(var.observability.enabled, false) && try(var.observability.agent, "") == "newrelic"

  env_dd = local.datadog ? {
    DD_ENV                               = var.org.environment_type
    DD_SERVICE                           = var.release.name
    DD_VERSION                           = try(var.release.source.version, "")
    DD_TAGS                              = try(var.observability.config.tags, "")
    DD_LOGS_ENABLED                      = try(var.observability.config.logs_enabled, true)
    DD_APM_ENABLED                       = try(var.observability.config.apm_enabled, true)
    DD_APM_NON_LOCAL_TRAFFIC             = try(var.observability.config.apm_non_local_traffic, true)
    DD_LOGS_INJECTION                    = try(var.observability.config.logs_injection, true)
    DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL = try(var.observability.config.logs_config_container_collect_all, true)
    DD_CONTAINER_EXCLUDE_LOGS            = try(var.observability.config.container_exclude_logs, "")
    DD_TRACE_DEBUG                       = try(var.observability.config.trace_debug, false)
    DD_DBM_PROPAGATION_MODE              = try(var.observability.config.dbm_propagation_mode, "full")
    DD_DOGSTATSD_NON_LOCAL_TRAFFIC       = try(var.observability.config.dogstatsd_non_local_traffic, true)
    DD_HTTP_CLIENT_ERROR_STATUSES        = try(var.observability.config.http_client_error_statuses, "400,401,403,404,405,409,410,429,500,501,502,503,504,505")
    DD_HTTP_SERVER_ERROR_STATUSES        = try(var.observability.config.http_server_error_statuses, "500,502,503,504,505")
  } : {}
  env_xray = local.xray ? {
    AWS_XRAY_TRACING_NAME = "${var.org.environment_type}/${var.release.name}/${var.release.source.version}"
  } : {}
  xrayConfigFilePath = try(var.observability.config.configFilePath, "/app/xray")
  xrayConfigFileName = try(var.observability.config.configFileName, "xray-agent.json")
  xray_index         = (local.secret_enabled ? 1 : 0) + (local.configmap_enabled ? 1 : 0)
  observability_overrides = zipmap(
    [
      "injectedVolumes[${local.xray_index}].name",
      "injectedVolumes[${local.xray_index}].configMap.name",
      "injectedVolumeMounts[${local.xray_index}].name",
      "injectedVolumeMounts[${local.xray_index}].mountPath",
    ],
    [
      "${var.release.name}-xray-cm",
      "${var.release.name}-xray-cm",
      "${var.release.name}-xray-cm",
      local.xrayConfigFilePath,
    ]
  )
  observability_envs = merge(local.env_dd, local.env_xray)
}

resource "kubernetes_config_map" "xray" {
  count = try(var.observability.enabled, false) && try(var.observability.agent, "") == "xray" ? 1 : 0
  metadata {
    name      = "${var.release.name}-xray-cm"
    namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata.0.name : data.kubernetes_namespace.this[0].metadata.0.name
  }
  data = {
    "${local.xrayConfigFileName}" = jsonencode({
      contextMissingStrategy    = try(var.observability.config.contextMissingStrategy, "LOG_ERROR")
      daemonAddress             = try(var.observability.config.daemonAddress, "127.0.0.1:2000")
      tracingEnabled            = try(var.observability.config.tracingEnabled, true)
      samplingStrategy          = try(var.observability.config.samplingStrategy, "CENTRAL")
      traceIdInjectionPrefix    = try(var.observability.config.traceIdInjectionPrefix, "")
      samplingRulesManifest     = try(var.observability.config.samplingRulesManifest, "")
      awsServiceHandlerManifest = try(var.observability.config.awsServiceHandlerManifest, "")
      awsSdkVersion             = try(var.observability.config.awsSdkVersion, 2)
      maxStackTraceLength       = try(var.observability.config.maxStackTraceLength, 50)
      streamingThreshold        = try(var.observability.config.streamingThreshold, 100)
      traceIdInjection          = try(var.observability.config.traceIdInjection, true)
      pluginsEnabled            = try(var.observability.config.pluginsEnabled, true)
      collectSqlQueries         = try(var.observability.config.collectSqlQueries, false)
    })
  }
}