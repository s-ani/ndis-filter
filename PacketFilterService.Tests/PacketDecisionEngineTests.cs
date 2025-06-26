using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PacketFilterService;
using Xunit;

namespace PacketFilterService.Tests
{
    public class PacketDecisionEngineTests
    {
        private readonly PacketDecisionEngine _engine = new PacketDecisionEngine();

        [Theory]
        [InlineData("192.168.1.100", 80, false)] // Blocked IP
        [InlineData("10.0.0.1", 22, false)]      // Blocked Port
        [InlineData("10.0.0.1", 80, true)]       // Allowed
        public void Decide_ReturnsExpectedResult(string ip, int port, bool expected)
        {
            var result = _engine.Decide(ip, port);
            Assert.Equal(expected, result);
        }

        [Theory]
        [InlineData("", 80)]                    // Empty IP
        [InlineData(null, 80)]                  // Null IP
        [InlineData("192.168.1.100", -1)]      // Negative port
        [InlineData("192.168.1.100", 70000)]   // Port out of range
        public void Decide_MalformedInput_DoesNotThrow(string ip, int port)
        {
            var exception = Record.Exception(() => _engine.Decide(ip, port));
            Assert.Null(exception); // Should not throw exception
        }
    }
}
