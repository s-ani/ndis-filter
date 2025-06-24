using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ServiceProcess;

namespace PacketFilterService
{
    // This class defines the core Windows Service logic.
    // It starts the packet handler on service start and stops it on service stop.
    public class PacketFilterService : ServiceBase
    {
        private NamedPipePacketHandler _handler;

        public PacketFilterService()
        {
            this.ServiceName = "PacketFilterService"; // Service name shown in Windows Services
        }

        // Called when the service is started
        protected override void OnStart(string[] args)
        {
            _handler = new NamedPipePacketHandler(); // Create handler instance
            Task.Run(() => _handler.Start());         // Start it in the background
        }

        // Called when the service is stopped
        protected override void OnStop()
        {
            _handler?.Stop(); // Stop the handler gracefully
        }
    }
}
