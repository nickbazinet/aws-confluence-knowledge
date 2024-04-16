from atlassian import Confluence


def download_file(confluence: Confluence, page_id: int, page_title: str, destination_dir: str):
    content = confluence.export_page(page_id)
    with open(destination_dir + str(page_id) + ".pdf", "wb") as pdf_file:
        pdf_file.write(content)
        pdf_file.close()
        print(f"Download for {page_title}.pdf completed")

def download_files(confluence: Confluence, space_name: str, destination_dir: str): 
    pgs = confluence.get_all_pages_from_space(
        space_name,
        0,
        limit=200,
        status="current",
        content_type="page",
    )

    for page in pgs:
        download_file(confluence, page.get("id"), page.get("title"), destination_dir)

