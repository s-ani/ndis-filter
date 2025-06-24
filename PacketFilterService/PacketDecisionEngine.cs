using System;
using System.Net;
using System.IO;

namespace PacketFilterService
{
    // Enhanced decision engine with validation and structured logic
    public class PacketDecisionEngine
    {
        private readonly string logPath = @"C:\PacketFilterLogs\log.txt";

        // Determines whether a given IP and port should be allowed or blocked
        public bool Decide(string ip, int port)
        {
            if (!IsValidIp(ip))
            {
                Log("Invalid IP format: " + ip);
                return false;
            }

            if (!IsValidPort(port))
            {
                Log($"Invalid port number: {port}");
                return false;
            }

            // Example business logic
            if (ip == "192.168.1.100")
            {
                Log("Blocked IP: " + ip);
                return false;
            }

            if (port == 22)
            {
                Log("Blocked port: " + port);
                return false;
            }

            // Allow everything else
            Log($"Allowed: {ip}:{port}");
            return true;
        }

        private bool IsValidIp(string ip)
        {
            return IPAddress.TryParse(ip, out _);
        }

        private bool IsValidPort(int port)
        {
            return port >= 0 && port <= 65535;
        }

        private void Log(string message)
        {
            File.AppendAllText(logPath, $"[DecisionEngine] {DateTime.Now:HH:mm:ss} - {message}");
        }
    }
}
