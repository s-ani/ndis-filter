using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.IO.Pipes;
using System.Threading;
using PacketFilterService;

namespace PacketFilterService
{
    // This class manages named pipe communication between the driver and the service.
    // It receives IP:Port messages, makes a decision, responds with allow/block, and logs the result.
    public class NamedPipePacketHandler
    {
        private bool _running = true;
        private const string PipeName = "PacketFilterPipe";
        private readonly string logPath = @"C:\\PacketFilterLogs\\log.txt";
        private readonly PacketDecisionEngine decisionEngine = new PacketDecisionEngine();

        // Start the named pipe server loop
        public void Start()
        {
            Directory.CreateDirectory(Path.GetDirectoryName(logPath));

            while (_running)
            {
                using (var pipe = new NamedPipeServerStream(PipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Message, PipeOptions.Asynchronous))
                {
                    pipe.WaitForConnection();

                    byte[] buffer = new byte[256];
                    int bytesRead = pipe.Read(buffer, 0, buffer.Length);
                    string request = Encoding.UTF8.GetString(buffer, 0, bytesRead);

                    string[] parts = request.Split(':'); // Expected format "IP:Port"
                    if (parts.Length != 2)
                    {
                        WriteToLog("Invalid input format received: " + request);
                        pipe.WriteByte(0); // Default block if invalid
                        continue;
                    }

                    string ip = parts[0];
                    int port = int.TryParse(parts[1], out int parsedPort) ? parsedPort : -1;

                    if (port == -1)
                    {
                        WriteToLog("Invalid port received: " + parts[1]);
                        pipe.WriteByte(0);
                        continue;
                    }

                    bool allow = decisionEngine.Decide(ip, port);
                    pipe.WriteByte(allow ? (byte)1 : (byte)0);
                    pipe.Flush();

                    WriteToLog($"{ip}:{port} => {(allow ? "ALLOW" : "BLOCK")}");
                }

                Thread.Sleep(100); // Small delay before next connection
            }
        }

        // Stop the server loop
        public void Stop()
        {
            _running = false;
        }

        // Log decision or errors
        private void WriteToLog(string message)
        {
            string log = $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {message}\n";
            File.AppendAllText(logPath, log);
        }
    }
}

