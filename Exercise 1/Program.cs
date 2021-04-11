using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Net.Http;

namespace Exercise1
{
    public class Ex1
    { 
        static async Task Main()
        {            
            var urlEndPoints = new List<string>(){"http://google.com", "http://github.com", "http://yahoo.com"};            
            var tasks = new List<Task<int>>();
            var fn = new Functions();
            int result = 0;

            using var cts = new CancellationTokenSource();            
            using HttpClient client = new HttpClient();
            CancellationToken ct = cts.Token;

            foreach(var url in urlEndPoints)
            {
                var tc = Task.Run(async () => await fn.MakeGetCall(url, client, ct), ct);
                Console.WriteLine("Task {0} executing", tc.Id);
                tasks.Add(tc);
            }
            
            try
            {
                var res = await Task.WhenAll(tasks.ToArray());
                
                Array.ForEach(res, val => result += val);
              
            }
            catch (OperationCanceledException e)
            {
                Console.WriteLine($"{nameof(OperationCanceledException)} thrown with message: {e.Message}");
            }
            finally
            {
                cts.Dispose();
            }

            Console.WriteLine($"Result = {result}");
        }
    }

    public class Functions
    {
        public async Task<int> MakeGetCall(string url, HttpClient httpClient, CancellationToken ct)
        {
            int aggregatedLength = 0;

            if (ct.IsCancellationRequested)
            {
                Cancel(ct);
            }
            else
            {
                var response = await httpClient.GetAsync(url, ct);

                if (ct.IsCancellationRequested)
                {
                    Cancel(ct);
                }
                else
                { 
                    if (response.IsSuccessStatusCode)
                    {
                        var respString = await response.Content.ReadAsStringAsync();
                        aggregatedLength += respString?.Length ?? 0;
                    }                    
                }
            }

            return aggregatedLength;

            static void Cancel(CancellationToken ct)
            {
                Console.WriteLine("Task cancelled");
                ct.ThrowIfCancellationRequested();
            }
        }
    }
}