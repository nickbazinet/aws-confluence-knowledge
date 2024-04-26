from requests import HTTPError

from atlassian import Confluence
from atlassian.request_utils import get_default_logger

log = get_default_logger(__name__)

class MdfConfluence(Confluence):

    def raise_for_status(self, response):
        """
        Custom method for mdf specific use case. This method will ignore all errors returned by 
        the remote server and will only display a warning.

        Checks the response for errors and throws an exception if return code >= 400
        Since different tools (Atlassian, Jira, ...) have different formats of returned json,
        this method is intended to be overwritten by a tool specific implementation.
        :param response:
        :return:
        """
        if response.status_code == 401 and response.headers.get("Content-Type") != "application/json;charset=UTF-8":
            raise HTTPError("Unauthorized (401)", response=response)

        if 400 <= response.status_code < 600:
            try:
                j = response.json()
                if self.url == "https://api.atlassian.com":
                    error_msg = "\n".join(["{}: {}".format(k, v) for k, v in j.items()])
                else:
                    error_msg_list = j.get("errorMessages", list())
                    errors = j.get("errors", dict())
                    if isinstance(errors, dict):
                        error_msg_list.append(errors.get("message", ""))
                    elif isinstance(errors, list):
                        error_msg_list.extend([v.get("message", "") if isinstance(v, dict) else v for v in errors])
                    error_msg = "\n".join(error_msg_list)
            except Exception as e:
                log.warn(e)
                #response.raise_for_status()
            else:
                log.warn(error_msg)
        #else:
            #response.raise_for_status()
