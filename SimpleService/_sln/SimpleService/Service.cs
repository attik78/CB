using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace SimpleService
{
    public partial class Service : ServiceBase
    {
        public Service()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            Logger.Info(String.Format("{0:yyyyMMdd HH:mm:ss.fff}:\t{1}", DateTime.UtcNow, "Service started"));
        }

        protected override void OnStop()
        {
            Logger.Info(String.Format("{0:yyyyMMdd HH:mm:ss.fff}:\t{1}", DateTime.UtcNow, "Service stopped"));
        }
    }
}
