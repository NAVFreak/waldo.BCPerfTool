table 62100 "PerfTool Suite Line WPT"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "PerfTool Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Editable = false;
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "Object Type"; Option)
        {
            Caption = 'Object Type to Run';
            InitValue = "Codeunit";
            OptionCaption = ',Table,,Report,,Codeunit,,,Page,Query,';
            OptionMembers = ,"Table",,"Report",,"Codeunit",,,"Page","Query",;
        }
        field(4; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = field("Object Type"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not Rec.HasInterfaceImplementation() then
                    "Procedure Name" := 'OnRun';
            end;
        }
        field(5; "Object Name"; Text[249])
        {
            Caption = 'Object Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = field("Object Type"), "Object ID" = field("Object ID")));
        }
        field(6; PerfToolCodeunit; Enum "PerfToolCodeunit WPT")
        {
            Caption = 'PerfTool Codeunit';
            DataClassification = CustomerContent;
        }
        field(8; "Procedure Name"; Text[30])
        {
            Caption = 'Procedure';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PerfToolCodeunitWPT: Interface "PerfToolCodeunit WPT";
                ProcDoesntExistErr: label 'Procedurename %1 Doesn''t exist', Comment = '%1 is the procedurename';
            begin
                if not Rec.HasInterfaceImplementation() then exit;

                PerfToolCodeunitWPT := Rec.PerfToolCodeunit;

                If not PerfToolCodeunitWPT.GetProcedures().Contains(Rec."Procedure Name") then
                    Error(ProcDoesntExistErr, Rec."Procedure Name")
            end;

            trigger OnLookup()
            var
                TempProcedureBufferWPT: Record "Procedure Buffer WPT" temporary;
                PerfToolCodeunitWPT: Interface "PerfToolCodeunit WPT";
                Procs: list of [Text[30]];
                Proc: Text[30];
            begin
                if not Rec.HasInterfaceImplementation() then exit;

                PerfToolCodeunitWPT := Rec.PerfToolCodeunit;
                Procs := PerfToolCodeunitWPT.GetProcedures();

                foreach Proc in Procs do begin
                    TempProcedureBufferWPT."Procedure" := Proc;
                    TempProcedureBufferWPT.Insert();
                end;

                If page.RunModal(page::"Procedure Lookup WPT", TempProcedureBufferWPT) = Action::LookupOK then
                    Rec.Validate("Procedure Name", TempProcedureBufferWPT."Procedure");
            end;
        }


        field(10; SelectLatestVersion; Boolean)
        {
            Caption = 'SelectLatestVersion';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "PerfTool Code", "Line No.")
        {
            Clustered = true;
        }
        key(CU; "PerfTool Code", "Object ID")
        {
        }
    }

    trigger OnDelete()
    begin
        ClearLog();
    end;

    procedure Run(ShowResults: Boolean)
    var
        RunSuiteLineMethWPT: Codeunit "Run SuiteLine Meth WPT";
    begin
        RunSuiteLineMethWPT.Run(Rec, ShowResults);
    end;

    procedure ClearLog()
    var
        PerfToolLogEntryWPT: Record "PerfTool Log Entry WPT";
    begin
        PerfToolLogEntryWPT.SetRange(Identifier, Rec.SystemId);
        PerfToolLogEntryWPT.ClearFilteredRecords();
    end;

    procedure CurrentTag(): Text[249]
    var
        PerfToolSuiteHeaderWPT: Record "PerfTool Suite Header WPT";
    begin
        If not PerfToolSuiteHeaderWPT.get(Rec."PerfTool Code") then exit('');

        CalcFields("Object Name");

        if PerfToolSuiteHeaderWPT.CurrentTag <> '' then
            exit(PerfToolSuiteHeaderWPT.CurrentTag + ' - ' + copystr(GetObjectName(), 1, 196));

        exit(GetObjectName());
    end;

    procedure GetObjectName(): Text[30]
    begin
        if Rec.HasInterfaceImplementation() then
            exit(Rec."Procedure Name")
        else
            exit(CopyStr(Rec."Object Name", 1, 30));
    end;

    procedure HasInterfaceImplementation(): Boolean
    begin
        exit(Enum::"PerfToolCodeunit WPT".Ordinals().Contains("Object ID"));
    end;

}
