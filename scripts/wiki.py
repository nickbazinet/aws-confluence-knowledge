from atlassian import Confluence


def download_file(confluence, page_id, page_title, destination_dir) -> str:
    content = confluence.export_page(page_id)
    local_file_path = destination_dir + str(page_id) + ".pdf" 
    with open(local_file_path, "wb") as pdf_file:
        pdf_file.write(content)
        pdf_file.close()
        print(f"Download for {page_title}.pdf completed")
    return local_file_path

def download_files(confluence: Confluence, space_name: str, destination_dir: str): 
    pgs = confluence.get_all_pages_from_space(
        space_name,
        0,
        limit=2000,
        status="current",
        content_type="page",
    )

    for page in pgs:
        download_file(confluence, page.get("id"), page.get("title"), destination_dir)

