using System;
using System.Data.SqlClient;
using System.Reflection;
using log4net.Core;

namespace SimpleService
{
    public static class Logger
    {
        private static readonly ILogger log;

        static Logger()
        {
            log = LoggerManager.GetLogger(Assembly.GetCallingAssembly(), "DefaultLogger");
        }

        public static void Info(String message)
        {
            log.Log(typeof(Logger), Level.Info, message, null);
        }

        public static void Error(Exception ex)
        {
            log.Log(typeof(Logger), Level.Error, ex.Message, ex);
        }

    }
}