using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.PhantomJS;

namespace SeleniumTest
{
    [TestClass]
    public class Test2
    {
        private string baseURL = "http://xld:8081/";
        IWebDriver driver;
        
        [TestMethod]
        [TestCategory("Selenium")]
        [Priority(1)]

        public void TestMethod1()
        {         
                driver = new ChromeDriver("SeleniumTest");
                driver.Navigate().GoToUrl(baseURL);
                driver.Manage().Window.Maximize();
                System.Collections.Generic.IList<IWebElement> links = driver.FindElements(By.TagName("a"));
                foreach (var link in links)
                {
                    if (link.Text == "Contact")
                    {
                        link.Click();
                        System.Collections.Generic.IList<IWebElement> newlinks = driver.FindElements(By.TagName("a"));
                        foreach (var newlink in newlinks)
                        {
                            if (newlink.Text == "Back to Home")
                            {
                                newlink.Click();
                                break;
                            }
                        }
                        break;
                    }
                }

                driver.Close();
                driver.Dispose();
     
           
        }

        [TestCleanup()]
        public void MyTestCleanup()
        {
            driver.Quit();
        }

        [TestInitialize()]
        public void MyTestInitialize()
        {
        }
    }
}
