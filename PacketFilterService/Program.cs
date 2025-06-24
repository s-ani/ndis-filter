using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace PacketFilterService
{
    // This is the main entry point for the Windows Service.
    // It registers the service with Windows Service Control Manager (SCM).
    internal static class Program
    {
        static void Main()
        {
            // Define the service(s) to run.
            ServiceBase[] ServicesToRun = new ServiceBase[]
            {
                new PacketFilterService() // Our custom service class
            };

            // Run the service. This hands control over to the SCM.
            ServiceBase.Run(ServicesToRun);
        }
    }
}

